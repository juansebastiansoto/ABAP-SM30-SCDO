**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

METHOD check_object.

  DATA: vl_count    TYPE i,
        vl_funcname TYPE rs38l-name.

* Check the change document
  IF me->v_object IS INITIAL.

    SELECT COUNT(*)
    FROM tcdob
    INTO vl_count
    WHERE tabname EQ me->v_viewname.

    CASE vl_count.
      WHEN 0. " Do not exist change document object.

        RAISE EXCEPTION TYPE zcx_sm30_scdo
          EXPORTING
            textid   = zcx_sm30_scdo=>not_found
            viewname = me->v_viewname.

      WHEN 1. " The view has an unique change document object

        SELECT SINGLE object
        FROM tcdob
        INTO me->v_object
        WHERE tabname EQ me->v_viewname.

      WHEN OTHERS. " The view has multiple change document objects and do not know who use

        RAISE EXCEPTION TYPE zcx_sm30_scdo
          EXPORTING
            textid   = zcx_sm30_scdo=>not_unique
            viewname = me->v_viewname.

    ENDCASE.

  ENDIF.

* Check if the object and the viewname are related
  SELECT COUNT(*)
  FROM tcdob
  INTO vl_count
  WHERE object  EQ me->v_object
    AND tabname EQ me->v_viewname.

  IF vl_count EQ 0.

    RAISE EXCEPTION TYPE zcx_sm30_scdo
      EXPORTING
        textid   = zcx_sm30_scdo=>not_related
        viewname = me->v_viewname
        object   = me->v_object.

  ENDIF.

* Check if the generation object exist
  SELECT COUNT(*)
  FROM tcdrp
  INTO vl_count
  WHERE object EQ me->v_object.

  IF vl_count EQ 0.

    RAISE EXCEPTION TYPE zcx_sm30_scdo
      EXPORTING
        textid   = zcx_sm30_scdo=>not_generation
        object   = me->v_object.

  ENDIF.

* Check if exist the WRITE_DOCUMENT function
  vl_funcname = me->get_function_name( ).

  CALL FUNCTION 'FUNCTION_EXISTS'
    EXPORTING
      funcname           = vl_funcname
    EXCEPTIONS
      function_not_exist = 1
      OTHERS             = 2.

  IF sy-subrc NE 0.

    RAISE EXCEPTION TYPE zcx_sm30_scdo
      EXPORTING
        textid   = zcx_sm30_scdo=>function_not_found.

  ENDIF.


ENDMETHOD.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
