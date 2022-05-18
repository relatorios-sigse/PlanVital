SELECT
        CASE  
            WHEN TRANTP02.Quien_Hace_Transaccion = 'SOCIEDAD' 
            OR TRANTP02.Quien_Hace_Transaccion = 'CONYUGE' THEN TRANTP02.Nombre_Razon_Social 
            ELSE  CASE 
                WHEN NOMBAPELL.APELLIDO_MATERNO <> '' THEN NOMBAPELL.APELLIDO_PATERNO || ' ' || NOMBAPELL.APELLIDO_MATERNO || ' ' || NOMBAPELL.NOMBRE 
                ELSE NOMBAPELL.APELLIDO_PATERNO || ' ' || NOMBAPELL.NOMBRE 
            END 
        END APELLIDOS_NOMBRES,
        TRANTP02.* 
    FROM
        (SELECT
            WFP.idprocess AS Id_Workflow,
            INST.tipoinst AS Tipo_de_Instrumento,
            TP02.serie AS Serie_del_Instrumento,
            TP02.unidades AS Unidades,
            TP02.precunit AS Precio_Unitario,
            TP02.valortotal AS Valor_total,
            CASE 
                WHEN TP02.compraventa  = 'C'     THEN 'COMPRA'     
                WHEN TP02.compraventa = 'V'     THEN 'VENTA'     
                ELSE '' 
            END AS Tipo_de_Movimiento,
            TP02.tir AS TIR,
            TP02.plazoinstrument AS Plazo_del_Instrumento,
            MONE.descmone AS Moneda_de_Emision,
            TP02.precunitmone AS Precio_Unitario_Moneda_Emision,
            TP02.fechatransaccio AS Fecha_de_Transaccion,
            TO_CHAR(TP02.fechatransaccio, 'YYYY-MM-DD') AS Fecha_de_Transaccion_Mod,
            TP02.intermediario AS Intermediario,
            TP02.titugara AS Titulo_Garantizado_S_N,
            TP02.nombreemisor AS Administrador_de_cartera,
            TP02.admicartsali AS Adm_de_Cartera_Saliente,
            TP02.valopartextr AS porc_valor_par_extranjero,
            TP02.tirextr AS tir_extranjera,
            TP02.nemotecnico AS Nemotecnico_del_Instrumento,
            TP02.idcuenmand AS Identificacion_de_la_cuenta_mandataria,
            TP02.contraparte AS Contraparte,
            TRIM(regexp_replace(TP02.nombrefinal,
            '\s+',
            ' ',
            'g')) AS Nombre_Razon_Social,
            TP02.rutfinal AS Rut_Nacional,
            TP02.pasaportefinal AS Rut_Extranjero,
            PAIS.pais AS Pais,
            CASE 
                WHEN TP02.pasaportefinal IS NULL THEN TRIM(TP02.rutfinal) 
                ELSE TRIM(TP02.pasaportefinal) 
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
            DYNgridtp02 TP02                  
                ON CONINT.OID = TP02.OIDABC5POOHLIRGKDS          
        LEFT JOIN
            DYNforminst INST                  
                ON INST.OID = TP02.OIDABC1RS7LR4LTCV5               
        LEFT JOIN
            DYNformmone MONE                  
                ON MONE.OID = TP02.OIDABCBB4BFT6BWGFE            
        LEFT JOIN
            DYNformpais PAIS                  
                ON PAIS.OID = TP02.OIDABCJYOUOBHK93AM             
        LEFT JOIN
            DYNformusrtran USUA 
                ON USUA.OID = TP02.OIDABCO2FDYARUDA9V                                                                      
        WHERE
            WFP.FGSTATUS <= 5              
            AND WFP.CDPROCESSMODEL=42) TRANTP02 
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
            ON NOMBAPELL.IDENTIFICADOR = TRANTP02.IDENTIFICADOR