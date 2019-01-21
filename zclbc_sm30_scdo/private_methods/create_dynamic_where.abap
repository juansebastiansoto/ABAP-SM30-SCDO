**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

METHOD create_dynamic_where.

  DATA: tl_range TYPE STANDARD TABLE OF crmselstr,
        tl_cond  TYPE STANDARD TABLE OF mcondition.

  DATA: wl_range TYPE crmselstr,
        wl_cond  TYPE mcondition.

  DATA: vl_key   TYPE LINE OF cf_t_fzwert.

  FIELD-SYMBOLS: <fsl_field> TYPE ANY.

  wl_range-sign   = 'I'.
  wl_range-option = 'EQ'.

  LOOP AT me->t_key INTO vl_key.

    CLEAR: wl_range-field,
           wl_range-low.

    UNASSIGN <fsl_field>.

    ASSIGN COMPONENT vl_key OF STRUCTURE im_input TO <fsl_field>.

    wl_range-field = vl_key.
    wl_range-low   = <fsl_field>.
    APPEND wl_range TO tl_range.

  ENDLOOP.

  CALL FUNCTION 'CRS_CREATE_WHERE_CONDITION'
    TABLES
      ti_range      = tl_range
      to_cond       = tl_cond
    EXCEPTIONS
      invalid_input = 1
      OTHERS        = 2.

  IF sy-subrc NE 0.
    CALL METHOD raise_system_exception.
  ENDIF.

  LOOP AT tl_cond into wl_cond.

    CONCATENATE re_where wl_cond-cond into re_where.

  ENDLOOP.

ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
