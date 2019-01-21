**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Private
**************************************************************************

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

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
