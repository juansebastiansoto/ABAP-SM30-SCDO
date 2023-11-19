class ZCX_SM30_SCDO definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of NOT_FOUND,
      msgid type symsgid value 'ZCA_SM30_SCDO',
      msgno type symsgno value '000',
      attr1 type scx_attrname value 'VIEWNAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NOT_FOUND .
  constants:
    begin of NOT_UNIQUE,
      msgid type symsgid value 'ZCA_SM30_SCDO',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'VIEWNAME',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NOT_UNIQUE .
  constants:
    begin of NOT_GENERATION,
      msgid type symsgid value 'ZCA_SM30_SCDO',
      msgno type symsgno value '003',
      attr1 type scx_attrname value 'OBJECT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NOT_GENERATION .
  constants:
    begin of NOT_RELATED,
      msgid type symsgid value 'ZCA_SM30_SCDO',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'OBJECT',
      attr2 type scx_attrname value 'VIEWNAME',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NOT_RELATED .
  constants:
    begin of FUNCTION_NOT_FOUND,
      msgid type symsgid value 'ZCA_SM30_SCDO',
      msgno type symsgno value '004',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FUNCTION_NOT_FOUND .
  data VIEWNAME type VIMDESC-VIEWNAME .
  data OBJECT type TCDOB-OBJECT .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !VIEWNAME type VIMDESC-VIEWNAME optional
      !OBJECT type TCDOB-OBJECT optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SM30_SCDO IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->VIEWNAME = VIEWNAME .
me->OBJECT = OBJECT .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
