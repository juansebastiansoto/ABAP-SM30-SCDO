**************************************************************************
*   Class attributes.                                                    *
**************************************************************************
Instantiation: Public
Message class:
State: Implemented
Final Indicator: X
R/3 Release: 700

**************************************************************************
*   Public section of class.                                             *
**************************************************************************
class ZCLBC_SM30_SCDO definition
  public
  final
  create public .

*"* public components of class ZCLBC_SM30_SCDO
*"* do not include other source files here!!
public section.

  methods CONSTRUCTOR
    importing
      IM_VIEWNAME type VIMDESC-VIEWNAME
      IM_OBJECT type TCDOB-OBJECT optional
    raising
      ZCX_SM30_SCDO
      CX_T100_MSG .
  methods ADD_RECORD_TABLE
    importing
      IM_DATA type ANY
      IM_ACTION type CHAR01 .
  methods SAVE_LOG
    raising
      ZCX_SM30_SCDO
      CX_T100_MSG .

**************************************************************************
*   Private section of class.                                            *
**************************************************************************
*"* private components of class ZCLBC_SM30_SCDO
*"* do not include other source files here!!
private section.

  data T_KEY type CF_T_FZWERT .
  data V_VIEWNAME type VIMDESC-VIEWNAME .
  data V_OBJECT type TCDOB-OBJECT .

  methods READ_TABL_DEF
    exporting
      EX_TABLE_DEFINITION type DD03TTYP
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
      IM_TABLE_DEFINITION type DD03TTYP .
  methods CREATE_DYNAMIC_WHERE
    importing
      IM_INPUT type ANY
    returning
      value(RE_WHERE) type STRING
    raising
      CX_T100_MSG .

**************************************************************************
*   Protected section of class.                                          *
**************************************************************************
*"* protected components of class ZCLBC_SM30_SCDO
*"* do not include other source files here!!
protected section.

  data O_TOTAL_TABLE type ref to DATA .
  constants C_INSERT_ACTION type CDHDR-CHANGE_IND value 'I'. "#EC NOTEXT
  constants C_UPDATE_ACTION type CDHDR-CHANGE_IND value 'U'. "#EC NOTEXT
  constants C_DELETE_ACTION type CDHDR-CHANGE_IND value 'D'. "#EC NOTEXT

  methods CREATE_DYNAMIC_TABLE
    importing
      IM_TABLE_DEFINITION type DD03TTYP
    raising
      CX_T100_MSG .
  methods READ_DATA_TABLE
    importing
      IM_INPUT type ANY
    exporting
      EX_OUTPUT type ANY
    raising
      CX_T100_MSG .

**************************************************************************
*   Types section of class.                                              *
**************************************************************************
*"* dummy include to reduce generation dependencies between
*"* class ZCLBC_SM30_SCDO and it's users.
*"* touched if any type reference has been changed

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
