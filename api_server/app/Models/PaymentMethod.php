<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PaymentMethod extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'card_holder_name',
        'card_number_encrypted',
        'card_last_four',
        'card_type',
        'expiry_month',
        'expiry_year',
        'is_default',
    ];

    protected $casts = [
        'is_default' => 'boolean',
    ];

    protected $hidden = [
        'card_number_encrypted', 
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }


    public function getCardIcon(): string
    {
        return match(strtolower($this->card_type)) {
            'visa' => '💳',
            'mastercard' => '💳',
            'amex' => '💳',
            default => '💳'
        };
    }

    /**
     * Maskelenmiş kart numarası
     */
    public function getMaskedCardNumber(): string
    {
        return '**** **** **** ' . $this->card_last_four;
    }
}
