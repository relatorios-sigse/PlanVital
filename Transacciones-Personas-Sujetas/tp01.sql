SELECT
        CASE  
            WHEN TRANTP01.Quien_Hace_Transaccion = 'SOCIEDAD' 
            OR TRANTP01.Quien_Hace_Transaccion = 'CONYUGE' THEN TRANTP01.Nombre_Razon_Social 
            ELSE  CASE 
                WHEN NOMBAPELL.APELLIDO_MATERNO <> '' THEN NOMBAPELL.APELLIDO_PATERNO || ' ' || NOMBAPELL.APELLIDO_MATERNO || ' ' || NOMBAPELL.NOMBRE 
                ELSE NOMBAPELL.APELLIDO_PATERNO || ' ' || NOMBAPELL.NOMBRE 
            END 
        END APELLIDOS_NOMBRES,
        REPLACE(TRANTP01.Rut_Nacional, '-','') Rut_Nacional_SinGuion,
        REPLACE(TRANTP01.Rut_Extranjero, '-','') Rut_Extranjero_SinGuion,
        REPLACE(TRANTP01.Identificador, '-','') Identificador_SinGuion,
        TRANTP01.* 
    FROM
        (SELECT
            WFP.idprocess AS Id_Workflow,
            TP01.fechatransaccio AS Fecha_de_Transaccion,
		 	TO_CHAR(TP01.fechatransaccio, 'YYYYMMDD') AS Fecha_de_Transaccion_Mod,
            TP01.foliotransaccio AS Folio_de_Transaccion,
            UPPER(INST.tipoinst)  AS Tipo_de_Instrumento,
            TP01.nemotecnico AS Nemotecnico,
            TP01.unidades AS Unidades,
            TP01.precunit AS Precio_Unitario,
            TP01.valortotal AS Valor_Total,
            CASE 
                WHEN TP01.compraventa  = 'C'     THEN 'COMPRA'     
                WHEN TP01.compraventa = 'V'     THEN 'VENTA'     
                ELSE '' 
            END AS Tipo_de_Movimiento,
            TP01.tir AS TIR,
            TP01.plazoinstrument AS Plazo,
            TP01.nombreemisor AS Administrador_de_Cartera,
            TRIM(regexp_replace(TP01.nombrefinal,
            '\s+',
            ' ',
            'g')) AS Nombre_Razon_Social,
            TP01.rutfinal AS Rut_Nacional,
            TP01.pasaportefinal AS Rut_Extranjero,
            CASE 
                WHEN TP01.pasaportefinal IS NULL THEN TRIM(TP01.rutfinal) 
                ELSE TRIM(TP01.pasaportefinal) 
            END Identificador,
            USUA.usuariotransacc Quien_Hace_Transaccion,
            CONINT.nombres Nombre_Completo_PS,
            1 AS Cantidad               
        FROM
            WFPROCESS WFP          
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG                  
                ON FORMREG.CDASSOC=WFP.CDASSOCREG          
        INNER JOIN
            DYNci CONINT                  
                ON FORMREG.OIDENTITYREG=CONINT.OID           
        INNER JOIN
            DYNgridtp01 TP01                  
                ON CONINT.OID = TP01.OIDABC060IY45OZU5N          
        LEFT JOIN
            DYNforminst INST                  
                ON INST.OID = TP01.OIDABCZL2149DGQ6VE                
        LEFT JOIN
            DYNformusrtran USUA 
                ON USUA.OID = TP01.OIDABCEWWUDCKAUC79                                                              
        WHERE
            WFP.FGSTATUS <= 5              
            AND WFP.CDPROCESSMODEL=42  
        UNION
        SELECT
            WFP.idprocess AS Id_Workflow,
            GRID.fechatransaccio AS Fecha_de_Transaccion,
		 	TO_CHAR(GRID.fechatransaccio, 'YYYYMMDD') AS Fecha_de_Transaccion_Mod,
            GRID.foliotransaccio AS Folio_de_Transaccion,
            UPPER(INST.tipoinstrumento)  AS Tipo_de_Instrumento,
            GRID.nemotecnico AS Nemotecnico,
            GRID.unidades AS Unidades,
            GRID.preciounitario3 AS Precio_Unitario,
            CAST(GRID.valortotal3 AS VARCHAR) AS Valor_Total,
            CASE 
                WHEN GRID.compraventa  = 'C'     THEN 'COMPRA'     
                WHEN GRID.compraventa = 'V'     THEN 'VENTA'     
                ELSE '' 
            END AS Tipo_de_Movimiento,
            GRID.tir AS TIR,
            '' AS Plazo,
            GRID.nombreemisor AS Administrador_de_Cartera,
            TRIM(regexp_replace(GRID.nombrefinal,
            '\s+',
            ' ',
            'g')) AS Nombre_Razon_Social,
            GRID.rutfinal AS Rut_Nacional,
            GRID.pasaportefinal AS Rut_Extranjero,
            CASE 
                WHEN GRID.pasaportefinal IS NULL THEN TRIM(GRID.rutfinal) 
                ELSE TRIM(GRID.pasaportefinal) 
            END Identificador,
            USUA.usuariotransacc Quien_Hace_Transaccion,
            CONINT.nombres Nombre_Completo_PS,
            1 AS Cantidad               
        FROM
            WFPROCESS WFP          
        INNER JOIN
            GNASSOCFORMREG FORMREG                  
                ON FORMREG.CDASSOC=WFP.CDASSOCREG          
        INNER JOIN
            DYNci CONINT                  
                ON FORMREG.OIDENTITYREG=CONINT.OID           
        INNER JOIN
            DYNgridtransaccion GRID                  
                ON CONINT.OID = GRID.OIDABCQHX6WA85BDDT          
        LEFT JOIN
            DYNforminstrumento INST                  
                ON INST.OID = GRID.OIDABCSLS4XD3HSZ1V                  
        LEFT JOIN
            DYNformusrtran USUA 
                ON USUA.OID = GRID.OIDABC46ER5AKHDDY9                                                           
        WHERE
            WFP.FGSTATUS <= 5              
            AND WFP.CDPROCESSMODEL=26
    ) TRANTP01 
LEFT JOIN
    (
        SELECT
            DISTINCT CASE 
                WHEN CONINT.NPASAPORTE IS NULL THEN TRIM(CONINT.RUT) 
                ELSE TRIM(CONINT.NPASAPORTE) 
            END IDENTIFICADOR,
            trim(CONINT.NOMBRES) NOMBRE,
            trim(CONINT.APELLIDOP) APELLIDO_PATERNO,
            trim(CONINT.APELLIDOM) APELLIDO_MATERNO 
        FROM
            WFPROCESS WFP  
        LEFT OUTER JOIN
            GNASSOCFORMREG FORMREG 
                ON FORMREG.CDASSOC=WFP.CDASSOCREG 
        INNER JOIN
            DYNci CONINT 
                ON FORMREG.OIDENTITYREG=CONINT.OID 
        WHERE
            WFP.FGSTATUS <= 5 
            AND WFP.CDPROCESSMODEL = 7
    ) NOMBAPELL 
        ON NOMBAPELL.IDENTIFICADOR = TRANTP01.IDENTIFICADOR 