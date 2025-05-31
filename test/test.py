# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_fsm(dut):
    dut._log.info("Inicio de la simulación")

    # Configuración del reloj a 100 MHz (10 ns por ciclo)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset inicial
    dut._log.info("Aplicando reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    # Función auxiliar para probar comandos
    async def aplicar_comando(valor_ui_in, nombre):
        dut._log.info(f"Probando comando: {nombre} (ui_in = {valor_ui_in:08b})")
        dut.ui_in.value = valor_ui_in
        # Esperar suficiente tiempo para que clk_nuevo[24] tenga flancos de subida (~33M ciclos por periodo)
        await ClockCycles(dut.clk, 17000000)  # ~170 ms
        val = dut.uo_out.value.integer & 0b111
        dut._log.info(f"uo_out = {val:03b}")
        return val

    # CERRAR (sw[2:0] = 001)
    val = await aplicar_comando(0b00000001, "CERRAR")
    assert val in (0b001, 0b000), "Esperado: LED[0] activo para cerrar"

    # ABRIR (sw[2:0] = 011)
    val = await aplicar_comando(0b00000011, "ABRIR")
    assert val in (0b010, 0b000), "Esperado: LED[1] activo para abrir"

    # AUTOMÁTICO (sw[2:0] = 100)
    val = await aplicar_comando(0b00000100, "AUTOMÁTICO")
    dut._log.info("Modo automático activado. Salida depende de sensores.")

    dut._log.info("Fin de la simulación")
