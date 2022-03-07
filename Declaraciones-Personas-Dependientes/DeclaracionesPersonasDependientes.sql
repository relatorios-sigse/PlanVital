SELECT
/**
Creación: 22-10-2020
Autor: Andrés Del Río

Modificaciones.
06-11-2020. Andrés Del Río. Se incluyó condición para no mostrar aquellos dependientes que pasaron como personas sujetas, ya que solo
deben mostrarse en el reporte de declaraciones 1a y 1b de personas sujetas. Ya se había incluido la regla de no mostrar los dependientes que habían
sido personas sujetas hace un año o menos.
09-12-2020. Andrés Del Río. Paso a producción tras validación por parte del cliente. Se comentan líneas con "AND WFP.CDPROCESSMODEL=34" y se descomentan líneas con "AND WFP.CDPROCESSMODEL=7"
y en las subqueries más internas se reemplazó "WF2.CDPROCESSMODEL = 34" por "WF2.CDPROCESSMODEL = 7" 
14-04-2021. Se restó un mes a las ocurrencias de fecha actual
**/
		(SELECT NMUSER FROM ADUSER WHERE IDUSER = REP.IDENTIFICADOR_REPORTE) NOMBRE_USUARIO_REPORTE,
        REP.ORDEN,
        REP.TIPO,
        REP.IDENTIFICADOR_REPORTE,
        REP.IDPROCESS,
        REP.NOMBRE_RS,
        REP.RUT,
        REP.TIPO_PERSONA,
        REP.CARGO,
        to_char(REP.FECHA_INICIO, 'YYYY') || to_char(REP.FECHA_INICIO, 'MM') || to_char(REP.FECHA_INICIO, 'DD') FECHA_INICIO,
        to_char(REP.FECHA_TERMINO, 'YYYY') || to_char(REP.FECHA_TERMINO, 'MM') || to_char(REP.FECHA_TERMINO, 'DD') FECHA_TERMINO,
        REP.RUT_RD,
        REP.NR,
        REP.PORC_PARTICIPACION,
        REP.CANTIDAD,
        REP.DESC_TIPO_PERSONA
    FROM
        (SELECT
            '1' ORDEN,
            'PERSONA DEPENDIENTE' TIPO,
            CONINT.IDENTIFICADOR IDENTIFICADOR_REPORTE,
            WFP.IDPROCESS,
            CASE WHEN CONINT.APELLIDOM <> '' THEN CONINT.APELLIDOP || ' ' || CONINT.APELLIDOM || ' ' || CONINT.NOMBRES 
        	ELSE CONINT.APELLIDOP || ' ' || CONINT.NOMBRES
            END NOMBRE_RS,
            CONINT.IDENTIFICADOR RUT,
            '1' TIPO_PERSONA,
            CASE WHEN CONINT.CARGO = 'Otros Relacionados' THEN '' ELSE UPPER(CONINT.CARGO) END CARGO,
		   	CONINT.fechaingreso FECHA_INICIO, 
            CONINT.fechatermino FECHA_TERMINO,
            '' RUT_RD,
            '' NR,
            CAST(NULL AS NUMERIC) PORC_PARTICIPACION,
            1 CANTIDAD,
            TIPOPERSONA.PERSONA DESC_TIPO_PERSONA
        FROM
            WFPROCESS WFP 
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG 
                ON FORMREG.CDASSOC=WFP.CDASSOCREG 
        INNER JOIN
            DYNci CONINT 
                ON FORMREG.OIDENTITYREG=CONINT.OID  
        LEFT OUTER JOIN
            DYNFORMCARGO RELACION 
                ON RELACION.OID = CONINT.OIDABCE0RCAPNY60DK
        LEFT OUTER JOIN 
            DYNFORMPERSONA TIPOPERSONA
                ON TIPOPERSONA.OID = CONINT.OIDABC00JGS4Y3SN89
        WHERE
            WFP.FGSTATUS <= 5 
            AND WFP.CDPROCESSMODEL=7
            --AND WFP.CDPROCESSMODEL=34
            AND TIPOPERSONA.IDPERSONA = 'GP-D' 
            AND (CONINT.fechatermino IS NULL OR ( date_part('month', CONINT.fechatermino) = date_part('month', (current_date - interval '1 month') ) AND
                                                  date_part('year', CONINT.fechatermino) = date_part('year', (current_date - interval '1 month' ) ) ))
            AND NOT EXISTS 
                (
                SELECT 1 
                FROM WFPROCESS WF2
                LEFT JOIN GNASSOCFORMREG FORMREG2 ON FORMREG2.CDASSOC=WF2.CDASSOCREG
                LEFT JOIN DYNci CONINT2 ON FORMREG2.OIDENTITYREG=CONINT2.OID 
                LEFT OUTER JOIN DYNFORMPERSONA TIPPERSONA2 ON TIPPERSONA2.OID = CONINT2.OIDABC00JGS4Y3SN89
                WHERE WF2.CDPROCESSMODEL = 7 
                AND WF2.FGSTATUS = 4 
                AND TIPPERSONA2.IDPERSONA = 'GP-S'
                AND CONINT2.IDENTIFICADOR = CONINT.IDENTIFICADOR
                AND CONINT2.fechatermino + interval '1 year' >= (current_date - interval '1 month')
                UNION
                SELECT 1 
                FROM WFPROCESS WF2
                LEFT JOIN GNASSOCFORMREG FORMREG2 ON FORMREG2.CDASSOC=WF2.CDASSOCREG
                LEFT JOIN DYNci CONINT2 ON FORMREG2.OIDENTITYREG=CONINT2.OID 
                LEFT OUTER JOIN DYNFORMPERSONA TIPPERSONA2 ON TIPPERSONA2.OID = CONINT2.OIDABC00JGS4Y3SN89
                WHERE WF2.CDPROCESSMODEL = 7 
                AND WF2.FGSTATUS = 1
                AND TIPPERSONA2.IDPERSONA = 'GP-S'
                AND CONINT2.IDENTIFICADOR = CONINT.IDENTIFICADOR
                AND CONINT2.fechaingreso >= CONINT.fechatermino
                )
        UNION
        SELECT
            '2' ORDEN,
            'SOCIEDADES DIRECTAS' TIPO,
            CONINT.IDENTIFICADOR IDENTIFICADOR_REPORTE,
            WFP.IDPROCESS,
            DIRECTA1A.RAZONSOCIAL NOMBRE_RS,
            DIRECTA1A.RUTEMPRESA RUT,
            '2' TIPO_PERSONA,
            CASE WHEN CONINT.CARGO = 'Otros Relacionados' THEN '' ELSE UPPER(CONINT.CARGO) END CARGO,
            CASE WHEN DIRECTA1A.fechaconstituci IS NULL THEN NULL 
            	 WHEN DIRECTA1A.fechaconstituci < CONINT.FECHAINGRESO THEN CONINT.FECHAINGRESO 
            	 ELSE DIRECTA1A.fechaconstituci 
            END FECHA_INICIO, 
            CASE WHEN DIRECTA1A.fechaterminosoc IS NOT NULL THEN DIRECTA1A.fechaterminosoc ELSE CONINT.fechatermino END FECHA_TERMINO,
            CONINT.IDENTIFICADOR RUT_RD,
            'D' NR,
            DIRECTA1A.dcparticipaciod PORC_PARTICIPACION,
            1 CANTIDAD,
            TIPOPERSONA.PERSONA DESC_TIPO_PERSONA        
        FROM
            WFPROCESS WFP 
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG 
                ON FORMREG.CDASSOC=WFP.CDASSOCREG 
        INNER JOIN
            DYNci CONINT 
                ON FORMREG.OIDENTITYREG=CONINT.OID  
        LEFT OUTER JOIN
            DYNFORMCARGO RELACION 
                ON RELACION.OID = CONINT.OIDABCE0RCAPNY60DK 
        INNER JOIN
            DYNgriddirecta DIRECTA1A 
                ON CONINT.OID = DIRECTA1A.OIDABCVYS8QF6JTCMG       
        LEFT OUTER JOIN 
            DYNFORMPERSONA TIPOPERSONA
                ON TIPOPERSONA.OID = CONINT.OIDABC00JGS4Y3SN89                                                               
        WHERE
            WFP.FGSTATUS <= 5 
            AND WFP.CDPROCESSMODEL=7
            --AND WFP.CDPROCESSMODEL=34
            AND TIPOPERSONA.IDPERSONA = 'GP-D'
            AND (CONINT.fechatermino IS NULL OR ( date_part('month', CONINT.fechatermino) = date_part('month', (current_date - interval '1 month')) AND
                                                  date_part('year', CONINT.fechatermino) = date_part('year', (current_date - interval '1 month')) ) )
            AND NOT EXISTS 
                (
                SELECT 1 
                FROM WFPROCESS WF2
                LEFT JOIN GNASSOCFORMREG FORMREG2 ON FORMREG2.CDASSOC=WF2.CDASSOCREG
                LEFT JOIN DYNci CONINT2 ON FORMREG2.OIDENTITYREG=CONINT2.OID 
                LEFT OUTER JOIN DYNFORMPERSONA TIPPERSONA2 ON TIPPERSONA2.OID = CONINT2.OIDABC00JGS4Y3SN89
                WHERE WF2.CDPROCESSMODEL = 7 
                AND WF2.FGSTATUS = 4 
                AND TIPPERSONA2.IDPERSONA = 'GP-S'
                AND CONINT2.IDENTIFICADOR = CONINT.IDENTIFICADOR
                AND CONINT2.fechatermino + interval '1 year' >= (current_date - interval '1 month')
                UNION
                SELECT 1 
                FROM WFPROCESS WF2
                LEFT JOIN GNASSOCFORMREG FORMREG2 ON FORMREG2.CDASSOC=WF2.CDASSOCREG
                LEFT JOIN DYNci CONINT2 ON FORMREG2.OIDENTITYREG=CONINT2.OID 
                LEFT OUTER JOIN DYNFORMPERSONA TIPPERSONA2 ON TIPPERSONA2.OID = CONINT2.OIDABC00JGS4Y3SN89
                WHERE WF2.CDPROCESSMODEL = 7 
                AND WF2.FGSTATUS = 1
                AND TIPPERSONA2.IDPERSONA = 'GP-S'
                AND CONINT2.IDENTIFICADOR = CONINT.IDENTIFICADOR
                AND CONINT2.fechaingreso >= CONINT.fechatermino
                )
        UNION
        SELECT
            '3' ORDEN,
            'SOCIEDADES INDIRECTAS' TIPO,
            CONINT.IDENTIFICADOR IDENTIFICADOR_REPORTE,
            WFP.IDPROCESS,
            INDIRECTA1A.RAZONSOCIALINDI NOMBRE_RS,
            INDIRECTA1A.RUTEMPRESAIND RUT,
            '2' TIPO_PERSONA,
            CASE WHEN CONINT.CARGO = 'Otros Relacionados' THEN '' ELSE UPPER(CONINT.CARGO) END CARGO,
            CASE WHEN INDIRECTA1A.fechaindirecta IS NULL THEN NULL 
            	 WHEN INDIRECTA1A.fechaindirecta < CONINT.FECHAINGRESO THEN CONINT.FECHAINGRESO 
            	 ELSE INDIRECTA1A.fechaindirecta 
            END FECHA_INICIO,
            CASE WHEN INDIRECTA1A.fechatermisocin IS NOT NULL THEN INDIRECTA1A.fechatermisocin ELSE CONINT.fechatermino END FECHA_TERMINO,
            CONINT.IDENTIFICADOR RUT_RD,
            'I' NR,
            INDIRECTA1A.dcpartipacioind PORC_PARTICIPACION,
            1 CANTIDAD,
            TIPOPERSONA.PERSONA DESC_TIPO_PERSONA      
        FROM
            WFPROCESS WFP 
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG 
                ON FORMREG.CDASSOC=WFP.CDASSOCREG 
        INNER JOIN
            DYNci CONINT 
                ON FORMREG.OIDENTITYREG=CONINT.OID  
        LEFT OUTER JOIN
            DYNFORMCARGO RELACION 
                ON RELACION.OID = CONINT.OIDABCE0RCAPNY60DK 
        INNER JOIN
            DYNgridindirecta INDIRECTA1A 
                ON CONINT.OID = INDIRECTA1A.OIDABCYJGWYLDQPSXY    
        LEFT OUTER JOIN 
            DYNFORMPERSONA TIPOPERSONA
                ON TIPOPERSONA.OID = CONINT.OIDABC00JGS4Y3SN89                                                                  
        WHERE
            WFP.FGSTATUS <= 5 
            AND WFP.CDPROCESSMODEL=7
            --AND WFP.CDPROCESSMODEL=34
            AND TIPOPERSONA.IDPERSONA = 'GP-D' 
            AND (CONINT.fechatermino IS NULL OR ( date_part('month', CONINT.fechatermino) = date_part('month', (current_date - interval '1 month')) AND
                                                  date_part('year', CONINT.fechatermino) = date_part('year', (current_date - interval '1 month')) ) )
            AND NOT EXISTS 
                (
                SELECT 1 
                FROM WFPROCESS WF2
                LEFT JOIN GNASSOCFORMREG FORMREG2 ON FORMREG2.CDASSOC=WF2.CDASSOCREG
                LEFT JOIN DYNci CONINT2 ON FORMREG2.OIDENTITYREG=CONINT2.OID 
                LEFT OUTER JOIN DYNFORMPERSONA TIPPERSONA2 ON TIPPERSONA2.OID = CONINT2.OIDABC00JGS4Y3SN89
                WHERE WF2.CDPROCESSMODEL = 7
                AND WF2.FGSTATUS = 4 
                AND TIPPERSONA2.IDPERSONA = 'GP-S'
                AND CONINT2.IDENTIFICADOR = CONINT.IDENTIFICADOR
                AND CONINT2.fechatermino + interval '1 year' >= (current_date - interval '1 month')
                UNION
                SELECT 1 
                FROM WFPROCESS WF2
                LEFT JOIN GNASSOCFORMREG FORMREG2 ON FORMREG2.CDASSOC=WF2.CDASSOCREG
                LEFT JOIN DYNci CONINT2 ON FORMREG2.OIDENTITYREG=CONINT2.OID 
                LEFT OUTER JOIN DYNFORMPERSONA TIPPERSONA2 ON TIPPERSONA2.OID = CONINT2.OIDABC00JGS4Y3SN89
                WHERE WF2.CDPROCESSMODEL = 7 
                AND WF2.FGSTATUS = 1
                AND TIPPERSONA2.IDPERSONA = 'GP-S'
                AND CONINT2.IDENTIFICADOR = CONINT.IDENTIFICADOR
                AND CONINT2.fechaingreso >= CONINT.fechatermino
                )
        
    ) REP 