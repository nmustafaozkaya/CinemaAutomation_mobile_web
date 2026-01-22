<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PaymentMethod;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Crypt;

class PaymentMethodController extends Controller
{
    /**
     * Kullanıcının ödeme yöntemlerini listele
     */
    public function index(): JsonResponse
    {
        $paymentMethods = PaymentMethod::where('user_id', Auth::id())
            ->orderBy('is_default', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $paymentMethods
        ]);
    }

    /**
     * Yeni ödeme yöntemi ekle
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'card_holder_name' => 'required|string|max:255',
            'card_number' => 'required|string|min:13|max:19',
            'card_type' => 'required|in:visa,mastercard,amex',
            'expiry_month' => 'required|string|size:2',
            'expiry_year' => 'required|string|size:4',
            'is_default' => 'boolean',
        ]);

        // Eğer bu default olarak işaretlenmişse, diğerlerini default'tan çıkar
        if ($validated['is_default'] ?? false) {
            PaymentMethod::where('user_id', Auth::id())
                ->update(['is_default' => false]);
        }

        // Kart numarasını şifrele
        $cardNumber = preg_replace('/\s+/', '', $validated['card_number']);
        $lastFour = substr($cardNumber, -4);

        $paymentMethod = PaymentMethod::create([
            'user_id' => Auth::id(),
            'card_holder_name' => $validated['card_holder_name'],
            'card_number_encrypted' => Crypt::encryptString($cardNumber),
            'card_last_four' => $lastFour,
            'card_type' => $validated['card_type'],
            'expiry_month' => $validated['expiry_month'],
            'expiry_year' => $validated['expiry_year'],
            'is_default' => $validated['is_default'] ?? false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Payment method added successfully',
            'data' => $paymentMethod
        ], 201);
    }

    /**
     * Ödeme yöntemini güncelle
     */
    public function update(Request $request, $id): JsonResponse
    {
        $paymentMethod = PaymentMethod::where('user_id', Auth::id())
            ->findOrFail($id);

        $validated = $request->validate([
            'card_holder_name' => 'sometimes|string|max:255',
            'expiry_month' => 'sometimes|string|size:2',
            'expiry_year' => 'sometimes|string|size:4',
            'is_default' => 'sometimes|boolean',
        ]);

        // Eğer default olarak işaretlenmişse, diğerlerini default'tan çıkar
        if (isset($validated['is_default']) && $validated['is_default']) {
            PaymentMethod::where('user_id', Auth::id())
                ->where('id', '!=', $id)
                ->update(['is_default' => false]);
        }

        $paymentMethod->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Payment method updated successfully',
            'data' => $paymentMethod
        ]);
    }

    /**
     * Ödeme yöntemini sil
     */
    public function destroy($id): JsonResponse
    {
        $paymentMethod = PaymentMethod::where('user_id', Auth::id())
            ->findOrFail($id);

        $paymentMethod->delete();

        return response()->json([
            'success' => true,
            'message' => 'Payment method deleted successfully'
        ]);
    }

    /**
     * Default ödeme yöntemini ayarla
     */
    public function setDefault($id): JsonResponse
    {
        $paymentMethod = PaymentMethod::where('user_id', Auth::id())
            ->findOrFail($id);

        // Diğerlerini default'tan çıkar
        PaymentMethod::where('user_id', Auth::id())
            ->where('id', '!=', $id)
            ->update(['is_default' => false]);

        $paymentMethod->update(['is_default' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Default payment method set successfully',
            'data' => $paymentMethod
        ]);
    }
}
