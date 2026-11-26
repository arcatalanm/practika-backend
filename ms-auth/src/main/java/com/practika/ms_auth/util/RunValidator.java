package com.practika.ms_auth.util;

public final class RunValidator {

    private RunValidator() {
    }

    public static boolean esValido(Integer run, Character dv) {
        if (run == null || run <= 0 || dv == null) {
            return false;
        }

        char dvNormalizado = Character.toUpperCase(dv);
        if (!Character.isDigit(dvNormalizado) && dvNormalizado != 'K') {
            return false;
        }

        return calcularDv(run) == dvNormalizado;
    }

    public static char calcularDv(int run) {
        int suma = 0;
        int multiplicador = 2;
        int numero = run;

        while (numero > 0) {
            suma += (numero % 10) * multiplicador;
            numero /= 10;
            multiplicador = multiplicador == 7 ? 2 : multiplicador + 1;
        }

        int resto = 11 - (suma % 11);
        if (resto == 11) {
            return '0';
        }
        if (resto == 10) {
            return 'K';
        }
        return Character.forDigit(resto, 10);
    }
}
