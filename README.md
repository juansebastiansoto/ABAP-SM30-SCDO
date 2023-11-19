# ABAP-SM30-SCDO

## What is SM30?

SM30 is a CRUD transaction to manage custom table data.

## What is SCDO?

SCDO (SAP Change Document Object) is the standard methodology to save data changes in standard tables.
You can create your own change document objects with the SCDO Transaction.

## Where are the SCDO data stored?

The log data will be saved in CDHDR & CDPOS tables.

## How can I see the log?

The RSSCD100 standard report is used to show CDHDR & CDPOS information.

Also, you can make your own report using the CHANGEDOCUMENT_READ and CHANGEDOCUMENT_DISPLAY function modules.

## What is this repository?

SM30-SCDO is an object class to save changes in SCDO without much work.

## How can I install de SM30-SCDO Class?

Clone the repo with abapGit.

# <a href="https://github.com/abapGit/"><img src="https://docs.abapgit.org/logo-dark.svg" alt="abapGit logo"></a>

## How can use it?

### 1.- Create a SCDO object (if not exist)

https://www.erpworkbench.com/abap/changedoc/cd_createch.htm

### 2.- Create the table maintenance  with SE11 Transaction

https://wiki.scn.sap.com/wiki/pages/viewpage.action?pageId=79953931

### 3.- Create a 01 event for this table.

https://musicodez.wordpress.com/2010/09/13/custom-validation-on-table-maintenance-generator-sm30/

### 4.- Invoke the SM30-SCDO Class

    DATA: ol_scdo TYPE REF TO zclbc_sm30_scdo,
          ox_scdo TYPE REF TO zcx_sm30_scdo,
          ox_t100 TYPE REF TO cx_t100_msg.

    TRY.

        CREATE OBJECT ol_scdo
          EXPORTING
            im_viewname = vim_object.

        LOOP AT total.

          CALL METHOD ol_scdo->add_record_table
            EXPORTING
              im_data   = <vim_total_struc>
              im_action = <action>.

        ENDLOOP.

        CALL METHOD ol_scdo->save_log.

      CATCH zcx_sm30_scdo INTO ox_scdo.

    * Insert your exception management	
	
      CATCH cx_t100_msg INTO ox_t100.

    * Insert your exception management	
	
    ENDTRY.
