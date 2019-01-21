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
class ZCX_SM30_SCDO definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

*"* public components of class ZCX_SM30_SCDO
*"* do not include other source files here!!
public section.

  constants NOT_UNIQUE type SOTR_CONC value 'E919AB302C3E28F189F5005056B110AB'. "#EC NOTEXT
  constants NOT_FOUND type SOTR_CONC value 'E919ABD6DF13FAF189F5005056B110AB'. "#EC NOTEXT
  constants NOT_GENERATION type SOTR_CONC value 'E919ACA6BAAF9AF189F5005056B110AB'. "#EC NOTEXT
  constants NOT_RELATED type SOTR_CONC value 'E919ABD6DF13FBF189F5005056B110AB'. "#EC NOTEXT
  constants FUNCTION_NOT_FOUND type SOTR_CONC value 'E919BBC3D5D58AF189F5005056B110AB'. "#EC NOTEXT
  data VIEWNAME type VIMDESC-VIEWNAME .
  data OBJECT type TCDOB-OBJECT .

  methods CONSTRUCTOR
    importing
      TEXTID like TEXTID optional
      PREVIOUS like PREVIOUS optional
      VIEWNAME type VIMDESC-VIEWNAME optional
      OBJECT type TCDOB-OBJECT optional .

**************************************************************************
*   Private section of class.                                            *
**************************************************************************
*"* private components of class ZCX_SM30_SCDO
*"* do not include other source files here!!
private section.

**************************************************************************
*   Protected section of class.                                          *
**************************************************************************
*"* protected components of class ZCX_SM30_SCDO
*"* do not include other source files here!!
protected section.

**************************************************************************
*   Types section of class.                                              *
**************************************************************************
*"* dummy include to reduce generation dependencies between
*"* class ZCX_SM30_SCDO and it's users.
*"* touched if any type reference has been changed

*Exception texts
*----------------------------------------------------------
* NOT_UNIQUE - There are multiple change document object for &VIEWNAME&. You must set one.
* NOT_FOUND - There are not change document object for &VIEWNAME&.
* NOT_GENERATION - The object &OBJECT& has not generation object.
* NOT_RELATED - The object &OBJECT& and the view &VIEWNAME& are not related.
* FUNCTION_NOT_FOUND - The WRITE_DOCUMENT function does not exist.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2019. Sap Release 700
