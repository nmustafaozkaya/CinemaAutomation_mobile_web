<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tax;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class TaxController extends Controller
{
    /**
     * Get active taxes
     */
    public function index(): JsonResponse
    {
        try {
            $taxes = Tax::where('status', 'active')
                       ->orderBy('priority')
                       ->get();

            return response()->json([
                'success' => true,
                'data' => $taxes
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Vergiler yüklenirken hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Calculate total with taxes
     */
    public function calculateTotal(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'subtotal' => 'required|numeric|min:0',
                'ticket_count' => 'required|integer|min:1'
            ]);

            $subtotal = $request->subtotal;
            $ticketCount = $request->ticket_count;

            // Aktif vergileri al
            $taxes = Tax::where('status', 'active')
                       ->orderBy('priority')
                       ->get();

            $taxDetails = [];
            $totalTaxAmount = 0;

            foreach ($taxes as $tax) {
                $taxAmount = 0;

                if ($tax->type === 'percentage') {
                    $taxAmount = ($subtotal * $tax->rate) / 100;
                } elseif ($tax->type === 'fixed') {
                    $taxAmount = $tax->rate * $ticketCount;
                } elseif ($tax->type === 'fixed_total') {
                    $taxAmount = $tax->rate;
                }

                $taxDetails[] = [
                    'name' => $tax->name,
                    'type' => $tax->type,
                    'rate' => $tax->rate,
                    'amount' => round($taxAmount, 2)
                ];

                $totalTaxAmount += $taxAmount;
            }

            $total = $subtotal + $totalTaxAmount;

            return response()->json([
                'success' => true,
                'data' => [
                    'subtotal' => round($subtotal, 2),
                    'taxes' => $taxDetails,
                    'total_tax_amount' => round($totalTaxAmount, 2),
                    'total' => round($total, 2),
                    'ticket_count' => $ticketCount
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Vergi hesaplaması yapılırken hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }
}

// Tax Model - app/Models/Tax.php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Tax extends Model
{
    protected $fillable = [
        'name',
        'type', // 'percentage', 'fixed', 'fixed_total'
        'rate',
        'status',
        'priority',
        'description'
    ];

    protected $casts = [
        'rate' => 'decimal:2',
        'priority' => 'integer'
    ];
}