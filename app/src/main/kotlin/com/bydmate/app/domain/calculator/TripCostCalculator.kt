package com.bydmate.app.domain.calculator

data class TripCost(
    val electricity: Double?,
    val fuel: Double?,
) {
    val total: Double = (electricity ?: 0.0) + (fuel ?: 0.0)
}

object TripCostCalculator {
    fun calculate(
        kwhConsumed: Double?,
        fuelLiters: Double?,
        electricityTariff: Double,
        fuelPricePerLiter: Double,
    ): TripCost? {
        val electricity = kwhConsumed
            ?.takeIf { it >= 0.0 }
            ?.times(electricityTariff.coerceAtLeast(0.0))
        val fuel = fuelLiters
            ?.takeIf { it >= 0.0 }
            ?.times(fuelPricePerLiter.coerceAtLeast(0.0))

        if (electricity == null && fuel == null) return null
        return TripCost(electricity = electricity, fuel = fuel)
    }
}
