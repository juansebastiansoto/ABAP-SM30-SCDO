class ZCLBC_SM30_SCDO definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IM_VIEWNAME type VIMDESC-VIEWNAME
      !IM_OBJECT type TCDOB-OBJECT optional
    raising
      ZCX_SM30_SCDO
      CX_T100_MSG .
  methods ADD_RECORD_TABLE
    importing
      !IM_DATA type ANY
      !IM_ACTION type CHAR01 .
  methods SAVE_LOG
    raising
      ZCX_SM30_SCDO
      CX_T100_MSG .
protected section.

  data O_TOTAL_TABLE type ref to DATA .
  constants C_INSERT_ACTION type CDHDR-CHANGE_IND value 'I' ##NO_TEXT.
  constants C_UPDATE_ACTION type CDHDR-CHANGE_IND value 'U' ##NO_TEXT.
  constants C_DELETE_ACTION type CDHDR-CHANGE_IND value 'D' ##NO_TEXT.

  methods CREATE_DYNAMIC_TABLE
    importing
      !IM_TABLE_DEFINITION type DD03TTYP
    raising
      CX_T100_MSG .
  methods READ_DATA_TABLE
    importing
      !IM_INPUT type ANY
    exporting
      !EX_OUTPUT type ANY
    raising
      CX_T100_MSG .
private section.

  data T_KEY type CF_T_FZWERT .
  data V_VIEWNAME type VIMDESC-VIEWNAME .
  data V_OBJECT type TCDOB-OBJECT .

  methods READ_TABL_DEF
    exporting
      !EX_TABLE_DEFINITION type DD03TTYP
    raising
      CX_T100_MSG .
  methods RAISE_SYSTEM_EXCEPTION
    raising
      CX_T100_MSG .
  methods CHECK_OBJECT
    raising
      ZCX_SM30_SCDO .
  methods GET_FUNCTION_NAME
    returning
      value(RE_FUNCTION_NAME) type RS38L-NAME .
  methods FILL_KEY_FIELDS
    importing
      !IM_TABLE_DEFINITION type DD03TTYP .
  methods CREATE_DYNAMIC_WHERE
    importing
      !IM_INPUT type ANY
    returning
      value(RE_WHERE) type STRING
    raising
      CX_T100_MSG .
ENDCLASS.



CLASS ZCLBC_SM30_SCDO IMPLEMENTATION.


METHOD add_record_table.

  DATA: ol_line TYPE REF TO data.

  FIELD-SYMBOLS: <fsl_table>        TYPE STANDARD TABLE,
                 <fsl_line>         TYPE ANY,
                 <fsl_action_field> TYPE ANY.

** Action values
** N = New entry
** U = Updated entry
** D = Deleted entry
** X = Deleted new entry
**   = Without changes

  IF im_action CA 'X '.
    RETURN.
  ENDIF.

  ASSIGN me->o_total_table->* TO <fsl_table>.

  CREATE DATA ol_line LIKE LINE OF <fsl_table>.
  ASSIGN ol_line->* TO <fsl_line>.

  MOVE-CORRESPONDING im_data TO <fsl_line>.

  ASSIGN COMPONENT 'ACTION' OF STRUCTURE <fsl_line> TO <fsl_action_field>.

  <fsl_action_field> = im_action.

  APPEND <fsl_line> TO <fsl_table>.

ENDMETHOD.


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


METHOD constructor.

  DATA: tl_table_definition TYPE dd03ttyp.

* Set the view or table name and the change data object
  me->v_viewname = im_viewname.
  me->v_object   = im_object.

* Check the change document object
  CALL METHOD me->check_object.

* Read table or view definition
  CALL METHOD me->read_tabl_def
    IMPORTING
      ex_table_definition = tl_table_definition.

* Fill key fields table
  CALL METHOD me->fill_key_fields
    EXPORTING
      im_table_definition = tl_table_definition.

* Use the table definition to create the dynamic table
  CALL METHOD me->create_dynamic_table
    EXPORTING
      im_table_definition = tl_table_definition.

ENDMETHOD.


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


METHOD fill_key_fields.

  DATA: wl_table_definition TYPE LINE OF dd03ttyp.

  LOOP AT im_table_definition INTO wl_table_definition WHERE fieldname NE 'MANDT'
                                                         AND keyflag   EQ abap_true.
    APPEND wl_table_definition-fieldname TO me->t_key.
  ENDLOOP.

ENDMETHOD.


METHOD get_function_name.

  CONCATENATE me->v_object
              '_WRITE_DOCUMENT'
  INTO re_function_name.

ENDMETHOD.


METHOD raise_system_exception.

  TYPES: BEGIN OF tyl_t100_msg_data,
           msgid  TYPE sy-msgid,
           msgno  TYPE sy-msgno,
           msgv1  TYPE string,
           msgv2  TYPE string,
           msgv3  TYPE string,
           msgv4  TYPE string,
         END OF tyl_t100_msg_data .

  DATA: wl_t100_msg TYPE tyl_t100_msg_data.

  MOVE-CORRESPONDING syst TO wl_t100_msg.

  RAISE EXCEPTION TYPE cx_t100_msg
    EXPORTING
      t100_msgid = wl_t100_msg-msgid
      t100_msgno = wl_t100_msg-msgno
      t100_msgv1 = wl_t100_msg-msgv1
      t100_msgv2 = wl_t100_msg-msgv2
      t100_msgv3 = wl_t100_msg-msgv3
      t100_msgv4 = wl_t100_msg-msgv4.

ENDMETHOD.


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


METHOD save_log.
*----------------------------------------------------------------------*
* Proy/Inc:     SR48497 : SAP [SD] - Remito Electrónico Harinero - [E1]
*               [Proyecto Cambio Menor\Cambio Legal]
* Funcional:    Panzini, Sebastián
* Técnico:      Panzini, Sebastián
* Fecha:        13.02.2020
* Descripción:  Se modifica metodo para poder permitir ejecutar un
*               objeto SCDO con mas de una tabla parametrizada
* Empresa:      Brightside IT Consulting
*----------------------------------------------------------------------*

  DATA: ol_line               TYPE REF TO data,
        ol_old_data           TYPE REF TO data,
        ol_data               TYPE REF TO data.             "add by sp001

  DATA: tl_function_import    TYPE abap_func_parmbind_tab,
        tl_tcdob              TYPE STANDARD TABLE OF tcdob. "add by sp001

  DATA: wl_function_import    TYPE LINE OF abap_func_parmbind_tab,
        wl_tcdob              TYPE tcdob.                   "add by sp001

  DATA: vl_key                TYPE LINE OF cf_t_fzwert,
        vl_objectid           TYPE cdhdr-objectid,
        vl_function_name      TYPE rs38l-name,
        vl_length             TYPE i,
        vl_offset             TYPE i.

  FIELD-SYMBOLS: <fsl_table>  TYPE ANY TABLE,
                 <fsl_line>   TYPE ANY,
                 <fsl_new>    TYPE ANY,
                 <fsl_old>    TYPE ANY,
                 <fsl_action> TYPE ANY,
                 <fsl_key>    TYPE ANY,
                 <fsl_structure> TYPE ANY.                   "add by sp001


* Get the function name
  vl_function_name = me->get_function_name( ).

  ASSIGN me->o_total_table->* TO <fsl_table>.

  CREATE DATA ol_line LIKE LINE OF <fsl_table>.
  ASSIGN ol_line->* TO <fsl_line>.

  CREATE DATA ol_old_data TYPE (me->v_viewname).
  ASSIGN ol_old_data->* TO <fsl_old>.

  LOOP AT <fsl_table> INTO <fsl_line>.

    CLEAR: tl_function_import,
           vl_objectid.

    ASSIGN COMPONENT 'ACTION' OF STRUCTURE <fsl_line> TO <fsl_action>.

    ASSIGN <fsl_line> TO <fsl_new> CASTING TYPE (me->v_viewname).

    IF <fsl_action> CA 'UD'.

      CLEAR <fsl_old>.

      CALL METHOD me->read_data_table
        EXPORTING
          im_input  = <fsl_new>
        IMPORTING
          ex_output = <fsl_old>.

    ENDIF.

*   The Object ID is the key table concatenated
    wl_function_import-name = 'OBJECTID'.
    wl_function_import-kind = abap_func_exporting.

    CLEAR: vl_offset.

    LOOP AT me->t_key INTO vl_key.

      UNASSIGN <fsl_key>.

      ASSIGN COMPONENT vl_key OF STRUCTURE <fsl_line> TO <fsl_key>.

      DESCRIBE FIELD <fsl_key> LENGTH vl_length IN CHARACTER MODE.

      vl_objectid+vl_offset(vl_length) = <fsl_key>.

      ADD vl_length TO vl_offset.

    ENDLOOP.

    GET REFERENCE OF vl_objectid INTO wl_function_import-value.
    INSERT wl_function_import INTO TABLE tl_function_import.

*   Transaction Code is not hardcoded because if use a Z transaction as shortcut this data will be lost.

    CLEAR wl_function_import.
    wl_function_import-name = 'TCODE'.
    wl_function_import-kind = abap_func_exporting.
    GET REFERENCE OF sy-tcode INTO wl_function_import-value.
    INSERT wl_function_import INTO TABLE tl_function_import.

*   System hour & date and User Name.
    CLEAR wl_function_import.
    wl_function_import-name = 'UTIME'.
    wl_function_import-kind = abap_func_exporting.
    GET REFERENCE OF sy-uzeit INTO wl_function_import-value.
    INSERT wl_function_import INTO TABLE tl_function_import.

    CLEAR wl_function_import.
    wl_function_import-name = 'UDATE'.
    wl_function_import-kind = abap_func_exporting.
    GET REFERENCE OF sy-datum INTO wl_function_import-value.
    INSERT wl_function_import INTO TABLE tl_function_import.

    CLEAR wl_function_import.
    wl_function_import-name = 'USERNAME'.
    wl_function_import-kind = abap_func_exporting.
    GET REFERENCE OF sy-uname INTO wl_function_import-value.
    INSERT wl_function_import INTO TABLE tl_function_import.

*   User action (Change, Insert, Delete)
    CLEAR wl_function_import.
    wl_function_import-name = 'OBJECT_CHANGE_INDICATOR'.
    wl_function_import-kind = abap_func_exporting.

    CASE <fsl_action>.
      WHEN 'N'.
        GET REFERENCE OF me->c_insert_action INTO wl_function_import-value.
      WHEN 'U'.
        GET REFERENCE OF me->c_update_action INTO wl_function_import-value.
      WHEN 'D'.
        GET REFERENCE OF me->c_delete_action INTO wl_function_import-value.
    ENDCASE.

    INSERT wl_function_import INTO TABLE tl_function_import.

    CONCATENATE 'UPD_'
                me->v_viewname
    INTO wl_function_import-name.

    INSERT wl_function_import INTO TABLE tl_function_import.

*   New values
    CLEAR: wl_function_import.

    CONCATENATE 'N_'
                me->v_viewname
    INTO wl_function_import-name.

    wl_function_import-kind = abap_func_exporting.
    GET REFERENCE OF <fsl_new> INTO wl_function_import-value.
    INSERT wl_function_import INTO TABLE tl_function_import.

*   Old values if was update or delete
    CLEAR: wl_function_import.

    CONCATENATE 'O_'
                me->v_viewname
    INTO wl_function_import-name.

    wl_function_import-kind = abap_func_exporting.
    GET REFERENCE OF <fsl_old> INTO wl_function_import-value.
    INSERT wl_function_import INTO TABLE tl_function_import.

*** BEGIN SP001
*" Se consulta si el objeto SCDO tiene mas de una tabla asignada.
    SELECT object tabname
      INTO TABLE tl_tcdob
      FROM tcdob
      WHERE object EQ me->v_object
        AND tabname NE me->v_viewname.
    IF sy-subrc EQ 0 AND NOT tl_tcdob[] IS INITIAL.
*" Se recorren las tablas y se cargan a la interfaz de la función
      LOOP AT tl_tcdob INTO wl_tcdob.
        CLEAR: ol_data.
        CREATE DATA ol_data TYPE (wl_tcdob-tabname).
        ASSIGN ol_data->* TO <fsl_structure>.

*" New values
        CLEAR: wl_function_import.
        CONCATENATE 'N_'
                    wl_tcdob-tabname
        INTO wl_function_import-name.
        wl_function_import-kind = abap_func_exporting.
        GET REFERENCE OF <fsl_structure> INTO wl_function_import-value.
        INSERT wl_function_import INTO TABLE tl_function_import.

*" Old values
        CLEAR: wl_function_import.
        CONCATENATE 'O_'
                    wl_tcdob-tabname
        INTO wl_function_import-name.
        wl_function_import-kind = abap_func_exporting.
        GET REFERENCE OF <fsl_structure> INTO wl_function_import-value.
        INSERT wl_function_import INTO TABLE tl_function_import.
      ENDLOOP.
    ENDIF.
*** END SP001

*   Call the function.
    CALL FUNCTION vl_function_name
      PARAMETER-TABLE
        tl_function_import.

  ENDLOOP.

ENDMETHOD.
ENDCLASS.
