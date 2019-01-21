**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

METHOD fill_key_fields.

  DATA: wl_table_definition TYPE LINE OF dd03ttyp.

  LOOP AT im_table_definition INTO wl_table_definition WHERE fieldname NE 'MANDT'
                                                         AND keyflag   EQ abap_true.
    APPEND wl_table_definition-fieldname TO me->t_key.
  ENDLOOP.

ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
