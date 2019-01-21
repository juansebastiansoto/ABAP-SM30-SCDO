**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

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

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
