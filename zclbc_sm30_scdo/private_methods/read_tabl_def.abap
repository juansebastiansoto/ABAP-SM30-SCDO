**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

METHOD read_tabl_def.

  DATA: vl_name TYPE ddobjname.

  vl_name = me->v_viewname.

  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = vl_name
    TABLES
      dd03p_tab     = ex_table_definition
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  IF sy-subrc NE 0.
    me->raise_system_exception( ).
  ENDIF.

ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
