**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Protected
**************************************************************************

METHOD create_dynamic_table.

  DATA tl_fieldcat          TYPE lvc_t_fcat.

  DATA: wl_table_definition TYPE LINE OF dd03ttyp,
        wl_fieldcat         TYPE LINE OF lvc_t_fcat.

* Fill the table definition

  LOOP AT im_table_definition INTO wl_table_definition.

    CLEAR wl_fieldcat.

    wl_fieldcat-fieldname = wl_table_definition-fieldname.
    wl_fieldcat-outputlen = wl_table_definition-outputlen.
    wl_fieldcat-tabname   = me->v_viewname.
    wl_fieldcat-ref_table = me->v_viewname.
    wl_fieldcat-ref_field = wl_table_definition-fieldname.
    wl_fieldcat-col_pos   = wl_table_definition-position.
    wl_fieldcat-key       = wl_table_definition-keyflag.

    APPEND wl_fieldcat TO tl_fieldcat.

    AT LAST.

      CLEAR wl_fieldcat.

      wl_fieldcat-fieldname = 'ACTION'.
      wl_fieldcat-outputlen = '1'.
      wl_fieldcat-col_pos   = LINES( tl_fieldcat ) + 1.

      APPEND wl_fieldcat TO tl_fieldcat.

    ENDAT.

  ENDLOOP.

* Create the dynamic table

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog           = tl_fieldcat
    IMPORTING
      ep_table                  = me->o_total_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  IF sy-subrc NE 0.
    me->raise_system_exception( ).
  ENDIF.


ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
