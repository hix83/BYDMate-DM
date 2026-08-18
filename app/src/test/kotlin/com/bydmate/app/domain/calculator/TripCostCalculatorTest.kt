package com.bydmate.app.domain.calculator

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class TripCostCalculatorTest {
    @Test
    fun combinesElectricityAndFuel() {
        val cost = TripCostCalculator.calculate(
            kwhConsumed = 2.4,
            fuelLiters = 0.35,
            electricityTariff = 5.0,
            fuelPricePerLiter = 60.0,
        )!!

        assertEquals(12.0, cost.electricity!!, 0.001)
        assertEquals(21.0, cost.fuel!!, 0.001)
        assertEquals(33.0, cost.total, 0.001)
    }

    @Test
    fun calculatesEitherEnergySourceWhenTheOtherIsMissing() {
        val electricOnly = TripCostCalculator.calculate(3.0, null, 4.0, 60.0)!!
        assertEquals(12.0, electricOnly.total, 0.001)
        assertNull(electricOnly.fuel)

        val fuelOnly = TripCostCalculator.calculate(null, 0.5, 4.0, 60.0)!!
        assertEquals(30.0, fuelOnly.total, 0.001)
        assertNull(fuelOnly.electricity)
    }

    @Test
    fun returnsNullWithoutConsumptionData() {
        assertNull(TripCostCalculator.calculate(null, null, 5.0, 60.0))
    }
}
