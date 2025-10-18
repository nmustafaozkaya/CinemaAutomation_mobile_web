<?php

// app/Enums/SeatStatus.php
namespace App\Enums;

enum SeatStatus: string
{
    case AVAILABLE = 'available';
    case OCCUPIED = 'occupied';
    case PENDING = 'pending';

    public function label(): string
    {
        return match($this) {
            self::AVAILABLE => 'Boş',
            self::OCCUPIED => 'Dolu',
            self::PENDING => 'Beklemede',
        };
    }

    public function color(): string
    {
        return match($this) {
            self::AVAILABLE => 'green',
            self::OCCUPIED => 'red',
            self::PENDING => 'yellow',
        };
    }
}