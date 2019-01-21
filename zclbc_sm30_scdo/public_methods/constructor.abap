**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
Instantiation: Public
**************************************************************************

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

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
