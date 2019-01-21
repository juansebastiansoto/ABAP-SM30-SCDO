**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Protected
**************************************************************************

METHOD read_data_table.

  DATA: vl_where TYPE string.

  CALL METHOD me->create_dynamic_where
    EXPORTING
      im_input = im_input
    RECEIVING
      re_where = vl_where.

  SELECT SINGLE *
  FROM (me->v_viewname)
  INTO ex_output
  WHERE (vl_where).

ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
