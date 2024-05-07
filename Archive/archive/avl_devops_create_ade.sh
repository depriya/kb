#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Exit immediately if a command fails
set -e

# Fail if an unset variable is used
set -u

source $(dirname $0)/symphony_stage_script_provider.sh

#region declare command variables & functions
command=""
_command_output=""
_command_status=0

function clear_command_variables() {
    command=""
    _command_output=""
    _command_status=0
}
#endregion declare command variables & functions

#region Declare Constants
COMPUTE_GALLERY="Computegalleryid"           #TODO: Discuss. Should this come from the config?
DEV_CENTER_CATALOG_NAME="catalog"            #TODO: Discuss. Should this come from the config?
ENVIRONMENT_DEFINITION_NAME="vmss"           #TODO: Discuss. Should this come from the config?
ENVIRONMENT_TYPE="sandbox"                   #TODO: Discuss. Should this come from the config?
ADMIN_USER="avluser"                         #TODO: Discuss and change, if needed
#admin_password="Password@123"                #TODO: Should get this from the Key Vault or Generate a new password and save it in the Key Vault
#MYOID="7cc6c11b-ad9c-43cc-a7d5-2a0a0e4f3648" #TODO: Discuss. How to get this value? As of now hardcoded objectid of AKS
echo "entering Object id command"
MYOID=$(az account get-access-token --query "accessToken" -o tsv | jq -R -r 'split(".") | .[1] | @base64d | fromjson | .oid')
echo "Object ID of the service principal or managed identity: $MYOID"
#endregion Declare Constants

#region Getting config from metamodel config yaml
configEncoded="eyJ2ZXJzaW9uIjogIjAuMS4wIiwgInN1YnNjcmlwdGlvbl9pZCI6ICJkYjQwMWI0Ny1mNjIyLTRlYjQtYTk5Yi1lMGNlYmMwZWJhZDQiLCAibWV0YV9tb2RlbF9vdXRwdXRzX2ZpbGVfc2hhcmVfbmFtZSI6ICJhdmxkZXZvcHMiLCAiZW52aXJvbm1lbnRfc3RhZ2Vfc2hvcnQiOiAiZCIsICJwcm9qZWN0X25hbWUiOiAicGoyIiwgInByb2plY3RfZGVzY3JpcHRpb24iOiAiUHJvamVjdCBEZXNjcmlwdGlvbiIsICJjdXN0b21lcl9PRU1fc3VmZml4IjogInRzdG9lbSIsICJyZXNvdXJjZV9uYW1lX3ByaW1hcnlfcHJlZml4IjogInhtZXcxIiwgInJlc291cmNlX25hbWVfc2Vjb25kYXJ5X3ByZWZpeCI6ICJkb3AiLCAicmVzb3VyY2VfbmFtZV9zaGFyZWRfc2hvcnQiOiAicyIsICJyZXNvdXJjZV9uYW1lX2N1c3RvbWVyX3Nob3J0IjogImMiLCAiamZyb2ciOiB7ImRvd25sb2FkX3VybCI6ICJodHRwczovL2F2bGFydGllZGdlZXcxLmpmcm9nLmlvL2FydGlmYWN0b3J5L2dlbmVyaWMvYXZsL3Ntcy82LjUvNTQ2MF8xMzcvSW5zdGFsbCUyMEFWTCUyMFNtYXJ0JTIwTW9iaWxlJTIwU29sdXRpb25zJTIwUjYuNSUyMEJ1aWxkJTIwNTQ2MF8xMzcuZXhlXFxcXCIsICJ0b2tlbl9zZWNyZXRfbmFtZSI6ICJKZnJvZ0VkZ2VUb2tlbiJ9LCAiY2xvbmVfZ2l0aHViX3JlcG9zaXRvcmllcyI6IFt7InJlcG9zaXRvcnkiOiAibW9kZWxfcmVsZWFzZXMiLCAib3JnYW5pemF0aW9uIjogImF2bC1zZHYiLCAicGF0X3Rva2VuX3NlY3JldF9uYW1lIjogIkdpdGh1YlBhdFRva2VuIn0sIHsicmVwb3NpdG9yeSI6ICJ4Y3VfcmVsZWFzZXMiLCAib3JnYW5pemF0aW9uIjogImF2bC1zZHYiLCAicGF0X3Rva2VuX3NlY3JldF9uYW1lIjogIkdpdGh1YlBhdFRva2VuIn0sIHsicmVwb3NpdG9yeSI6ICJQcm9qZWN0c19SZXBvIiwgIm9yZ2FuaXphdGlvbiI6ICJhdmwtc2R2IiwgInBhdF90b2tlbl9zZWNyZXRfbmFtZSI6ICJHaXRodWJQYXRUb2tlbiJ9XSwgIm1vZGVsX3N0YWNrIjogeyJtb2RlbF9yZXBvX293bmVyIjogIjxNT0RFTF9SRVBPX09XTkVSPiIsICJtb2RlbF9yZXBvX25hbWUiOiAiPE1PREVMX1JFUE9fTkFNRT4iLCAiTW9kdWxlc0xpYnJhcnkiOiB7IlBsYW50TW9kZWxMaWJyYXJ5IjogW3siQmxvY2tOYW1lIjogIkJFVl9UcnVja19NZGwiLCAiUm9vdFBhdGgiOiAiIiwgIlN1YlN5cyI6IFt7Ik5hbWUiOiAiQkVWX1RydWNrXzFTcGQiLCAiTW9kdWxlRmlsZVBhdGgiOiAibW9kZWxfcmVsZWFzZXMvVmVoaWNsZS9CRVZfVHJ1Y2tfMVNwZC92MS4wL0ZNVS9CRVZfVHJ1Y2tfMVNwZC5mbXUiLCAiVGltZVN0ZXBTaXplIjogIk5vbmUiLCAiU3ViU3lzUGFyYW0iOiBbeyJQYXJhbSI6ICJCRVZfVHJ1Y2tfMVNwZF9kZWZhdWx0IiwgIlBhcmFtRmlsZVBhdGgiOiAibW9kZWxfcmVsZWFzZXMvVmVoaWNsZS9CRVZfVHJ1Y2tfMVNwZC92MS4wL3BhcmFtL0JFVl9UcnVja18xU3BkX2RlZmF1bHQuZGNtIn1dfV19LCB7IkJsb2NrTmFtZSI6ICJEcml2ZXJfTWRsIiwgIlJvb3RQYXRoIjogIiIsICJTdWJTeXMiOiBbeyJOYW1lIjogIkRyaXZlciIsICJNb2R1bGVGaWxlUGF0aCI6ICJtb2RlbF9yZWxlYXNlcy9Ecml2ZXIvdjEuMC9GTVUvRHJpdmVyLmZtdSIsICJUaW1lU3RlcFNpemUiOiAiTm9uZSIsICJYQ1BTZXR0aW5ncyI6IHsiWENQU2xhdmUiOiAiTm9uZSIsICJIb3N0SVAiOiAiTm9uZSIsICJQb3J0IjogIk5vbmUifSwgIlN1YlN5c1BhcmFtIjogW3siUGFyYW0iOiAiRHJpdmVyX2RlZmF1bHQiLCAiUGFyYW1GaWxlUGF0aCI6ICJtb2RlbF9yZWxlYXNlcy9Ecml2ZXIvdjEuMC9wYXJhbS9Ecml2ZXJfZGVmYXVsdC5kY20ifV19XX0sIHsiQmxvY2tOYW1lIjogIlRNU19NZGwiLCAiUm9vdFBhdGgiOiAiIiwgIlN1YlN5cyI6IFt7Ik5hbWUiOiAiVE1TIiwgIk1vZHVsZUZpbGVQYXRoIjogIm1vZGVsX3JlbGVhc2VzL1RNUy92My4wL0ZNVS9UTVMuZm11IiwgIlRpbWVTdGVwU2l6ZSI6ICJOb25lIiwgIlhDUFNldHRpbmdzIjogeyJYQ1BTbGF2ZSI6ICJOb25lIiwgIkhvc3RJUCI6ICJOb25lIiwgIlBvcnQiOiAiTm9uZSJ9LCAiU3ViU3lzUGFyYW0iOiBbeyJQYXJhbSI6ICJUTVNfZGVmYXVsdCIsICJQYXJhbUZpbGVQYXRoIjogIm1vZGVsX3JlbGVhc2VzL1RNUy92My4wL3BhcmFtL1RNU19kZWZhdWx0LmRjbSJ9XX1dfSwgeyJCbG9ja05hbWUiOiAiQ2FiaW5fTWRsIiwgIlJvb3RQYXRoIjogIiIsICJTdWJTeXMiOiBbeyJOYW1lIjogIlNpbXBsZV9DYWJpbiIsICJNb2R1bGVGaWxlUGF0aCI6ICJtb2RlbF9yZWxlYXNlcy9DYWJpbi92Mi4wL0ZNVS9TaW1wbGVfQ2FiaW4uZm11IiwgIlRpbWVTdGVwU2l6ZSI6ICJOb25lIiwgIlhDUFNldHRpbmdzIjogeyJYQ1BTbGF2ZSI6ICJOb25lIiwgIkhvc3RJUCI6ICJOb25lIiwgIlBvcnQiOiAiTm9uZSJ9LCAiU3ViU3lzUGFyYW0iOiBbeyJQYXJhbSI6ICJTaW1wbGVfQ2FiaW5fZGVmYXVsdCIsICJQYXJhbUZpbGVQYXRoIjogIm1vZGVsX3JlbGVhc2VzL0NhYmluL3YyLjAvUGFyYW0vU2ltcGxlX0NhYmluX2RlZmF1bHQuZGNtIn1dfV19XX0sICJQcmVkZWZpbmVkRHJpdmVDeWNsZUxpYnJhcnkiOiBbeyJCbG9ja05hbWUiOiAiRHJpdmVDeWNsZV9NZGwiLCAiUm9vdFBhdGgiOiAiIiwgIlN1YlN5cyI6IFt7Ik5hbWUiOiAiRHJpdmVDeWNsZSIsICJNb2R1bGVGaWxlUGF0aCI6ICJtb2RlbF9yZWxlYXNlcy9Ecml2ZUN5Y2xlL3YyLjAvRHJpdmVDeWNsZV9CdWlsdC1pbi9GTVUvRHJpdmVDeWNsZS5mbXUiLCAiVGltZVN0ZXBTaXplIjogIk5vbmUiLCAiWENQU2V0dGluZ3MiOiB7IlhDUFNsYXZlIjogIk5vbmUiLCAiSG9zdElQIjogIk5vbmUiLCAiUG9ydCI6ICJOb25lIn0sICJTdWJTeXNQYXJhbSI6IFtdfV19XSwgIkNvbnRyb2xsZXJNb2RlbExpYnJhcnkiOiBbeyJCbG9ja05hbWUiOiAiVmVoaWNsZUN0cmxfRUNVIiwgIlJvb3RQYXRoIjogIiIsICJTdWJTeXMiOiBbeyJOYW1lIjogIlZDVSIsICJNb2R1bGVGaWxlUGF0aCI6ICJ4Y3VfcmVsZWFzZXMvVmVoaWNsZUNvbnRyVW5pdC92My4wL0ZNVS9WQ1UuZm11IiwgIlRpbWVTdGVwU2l6ZSI6ICJOb25lIiwgIlhDUFNldHRpbmdzIjogeyJYQ1BTbGF2ZSI6ICJOb25lIiwgIkhvc3RJUCI6ICJOb25lIiwgIlBvcnQiOiAiTm9uZSJ9LCAiU3ViU3lzUGFyYW0iOiBbeyJQYXJhbSI6ICJWZWhpY2xlQ29udHJfZGVmYXVsdCIsICJQYXJhbUZpbGVQYXRoIjogInhjdV9yZWxlYXNlcy9WZWhpY2xlQ29udHJVbml0L3YxLjAvcGFyYW0vVmVoaWNsZUNvbnRyX2RlZmF1bHQuZGNtIn1dfV19LCB7IkJsb2NrTmFtZSI6ICJUcmFuc21pc3Npb25DdHJsX0VDVSIsICJSb290UGF0aCI6ICIiLCAiU3ViU3lzIjogW3siTmFtZSI6ICJUQ1VfU2ltcGxlIiwgIk1vZHVsZUZpbGVQYXRoIjogInhjdV9yZWxlYXNlcy9UcmFuc21pc3Npb25Db250clVuaXQvdjEuMC9GTVUvVENVX1NpbXBsZS5mbXUiLCAiVGltZVN0ZXBTaXplIjogIk5vbmUiLCAiWENQU2V0dGluZ3MiOiB7IlhDUFNsYXZlIjogIk5vbmUiLCAiSG9zdElQIjogIk5vbmUiLCAiUG9ydCI6ICJOb25lIn0sICJTdWJTeXNQYXJhbSI6IFt7IlBhcmFtIjogIlRyYW5zbWlzc2lvbkNvbnRyX2RlZmF1bHQiLCAiUGFyYW1GaWxlUGF0aCI6ICJ4Y3VfcmVsZWFzZXMvVHJhbnNtaXNzaW9uQ29udHJVbml0L3YxLjAvcGFyYW0vVHJhbnNtaXNzaW9uQ29udHJfZGVmYXVsdC5kY20ifV19XX0sIHsiQmxvY2tOYW1lIjogIlRNU0N0cmxfRUNVIiwgIlJvb3RQYXRoIjogIiIsICJTdWJTeXMiOiBbeyJOYW1lIjogIkNvbnRyb2xsZXJfTmV4dEVUcnVja18yMDIzIiwgIk1vZHVsZUZpbGVQYXRoIjogInhjdV9yZWxlYXNlcy9UTVNDb250ci92MS4wL0ZNVS9Db250cm9sbGVyX05leHRFVHJ1Y2tfMjAyMy5mbXUiLCAiVGltZVN0ZXBTaXplIjogIk5vbmUiLCAiWENQU2V0dGluZ3MiOiB7IlhDUFNsYXZlIjogIk5vbmUiLCAiSG9zdElQIjogIk5vbmUiLCAiUG9ydCI6ICJOb25lIn0sICJTdWJTeXNQYXJhbSI6IFt7IlBhcmFtIjogIlRNU0NvbnRyX2RlZmF1bHQiLCAiUGFyYW1GaWxlUGF0aCI6ICJ4Y3VfcmVsZWFzZXMvVE1TQ29udHIvdjEuMC9wYXJhbS9UTVNDb250cl9kZWZhdWx0LmRjbSJ9XX1dfSwgeyJCbG9ja05hbWUiOiAiRUF4bGVDdHJsX0VDVSIsICJSb290UGF0aCI6ICIiLCAiU3ViU3lzIjogW3siTmFtZSI6ICJFQXhsZV9Db250cm9sbGVyIiwgIk1vZHVsZUZpbGVQYXRoIjogInhjdV9yZWxlYXNlcy9FQXhsZUNvbnRyVW5pdC9FQXhsZV9Db250cm9sbGVyL3YxLjAvRk1VL0VBeGxlX0NvbnRyb2xsZXIuZm11IiwgIlRpbWVTdGVwU2l6ZSI6ICJOb25lIiwgIlhDUFNldHRpbmdzIjogeyJYQ1BTbGF2ZSI6ICJOb25lIiwgIkhvc3RJUCI6ICJOb25lIiwgIlBvcnQiOiAiTm9uZSJ9LCAiU3ViU3lzUGFyYW0iOiBbeyJQYXJhbSI6ICJFQXhsZV9DdHJsX2RlZmF1bHQiLCAiUGFyYW1GaWxlUGF0aCI6ICJ4Y3VfcmVsZWFzZXMvRUF4bGVDb250clVuaXQvRUF4bGVfQ29udHJvbGxlci92MS4xL3BhcmFtL0VBeGxlX0N0cmxfZGVmYXVsdC5kY20ifV19XX0sIHsiQmxvY2tOYW1lIjogIkNoYXJnaW5nQ3RybF9FQ1UiLCAiUm9vdFBhdGgiOiAiIiwgIlN1YlN5cyI6IFt7Ik5hbWUiOiAiQ2hhcmdpbmdDb250cm9sVW5pdCIsICJNb2R1bGVGaWxlUGF0aCI6ICJ4Y3VfcmVsZWFzZXMvQ2hhcmdpbmdDb250clVuaXQvdjEuMC9GTVUvQ2hhcmdpbmdDb250cm9sVW5pdC5mbXUiLCAiVGltZVN0ZXBTaXplIjogIk5vbmUiLCAiWENQU2V0dGluZ3MiOiB7IlhDUFNsYXZlIjogIk5vbmUiLCAiSG9zdElQIjogIk5vbmUiLCAiUG9ydCI6ICJOb25lIn0sICJTdWJTeXNQYXJhbSI6IFt7IlBhcmFtIjogIkNoYXJnaW5nVW5pdENvbnRyX2RlZmF1bHQiLCAiUGFyYW1GaWxlUGF0aCI6ICJ4Y3VfcmVsZWFzZXMvQ2hhcmdpbmdDb250clVuaXQvdjEuMC9wYXJhbS9DaGFyZ2luZ1VuaXRDb250cl9kZWZhdWx0LmRjbSJ9XX1dfSwgeyJCbG9ja05hbWUiOiAiQ2FiaW5Db250cl9FQ1UiLCAiUm9vdFBhdGgiOiAiIiwgIlN1YlN5cyI6IFt7Ik5hbWUiOiAiQ2FiaW5fQ29udHJvbGxlciIsICJNb2R1bGVGaWxlUGF0aCI6ICJ4Y3VfcmVsZWFzZXMvQ2FiaW5Db250clVuaXQvdjEuMC9GTVUvQ2FiaW5fQ29udHJvbGxlci5mbXUiLCAiVGltZVN0ZXBTaXplIjogIk5vbmUiLCAiWENQU2V0dGluZ3MiOiB7IlhDUFNsYXZlIjogIk5vbmUiLCAiSG9zdElQIjogIk5vbmUiLCAiUG9ydCI6ICJOb25lIn0sICJTdWJTeXNQYXJhbSI6IFt7IlBhcmFtIjogIkNhYmluQ29udHJfZGVmYXVsdCIsICJQYXJhbUZpbGVQYXRoIjogInhjdV9yZWxlYXNlcy9DYWJpbkNvbnRyVW5pdC92MS4wL3BhcmFtL0NhYmluQ29udHJfZGVmYXVsdC5kY20ifV19XX1dLCAiU3RpbXVsaUxpYnJhcnkiOiBbeyJCbG9ja05hbWUiOiAiQ2hhcmdpbmdTdGF0aW9uIiwgIlJvb3RQYXRoIjogIiIsICJTdWJTeXMiOiBbeyJOYW1lIjogIkNoYXJnaW5nU3RhdGlvbiIsICJNb2R1bGVGaWxlUGF0aCI6ICJQcm9qZWN0c19SZXBvL05leHQtRS1UcnVjay9TdGltdWxpL0NTVi9DaGFyZ2luZ19TdGF0aW9uL0NoYXJnaW5nU3RhdGlvbi5jc3YifV19LCB7IkJsb2NrTmFtZSI6ICJQb3dlcnRyYWluX1RyYW5zaWVudCIsICJSb290UGF0aCI6ICIiLCAiU3ViU3lzIjogW3siTmFtZSI6ICJQb3dlcnRyYWluVHJhbnNpZW50IiwgIk1vZHVsZUZpbGVQYXRoIjogIlByb2plY3RzX1JlcG8vTmV4dC1FLVRydWNrL1N0aW11bGkvQ1NWL1Bvd2VydHJhaW5fVHJhbnNpZW50L1Bvd2VydHJhaW5UcmFuc2llbnQuY3N2In1dfSwgeyJCbG9ja05hbWUiOiAiQ3ljbGVfU3dpdGNoIiwgIlJvb3RQYXRoIjogIiIsICJTdWJTeXMiOiBbeyJOYW1lIjogIkN5Y2xlU3dpdGNoIiwgIk1vZHVsZUZpbGVQYXRoIjogIlByb2plY3RzX1JlcG8vTmV4dC1FLVRydWNrL1N0aW11bGkvQ1NWL0N5Y2xlX1N3aXRjaC9DeWNsZVN3aXRjaC5jc3YifV19XSwgIlVzZXJGdW5jdGlvbkxpYnJhcnkiOiBbeyJCbG9ja05hbWUiOiAiRnVuY19Ub3RhbF9QV0QiLCAiUm9vdFBhdGgiOiAiIiwgIlN1YlN5cyI6IFt7Ik5hbWUiOiAiRnVuY19Ub3RhbF9Qb3dlcl9EZW1hbmQiLCAiTW9kdWxlRmlsZVBhdGgiOiAiUHJvamVjdHNfUmVwby9OZXh0LUUtVHJ1Y2svRnVuY3Rpb25zL1RvdGFsX1Bvd2VyX0RlbWFuZC9GdW5jX1RvdGFsX1Bvd2VyX0RlbWFuZC5weSJ9XX1dLCAiQ29uc3RhbnRMaWJyYXJ5IjogW3siQmxvY2tOYW1lIjogIkJDXzAxIiwgIlN1YlN5cyI6IFt7Ik5hbWUiOiAiUkhhaXJfQW1iIiwgIlZhbHVlIjogMC4zLCAiVW5pdCI6ICJkaW1lbnNpb25sZXNzfm5vbmUifSwgeyJOYW1lIjogIlRhaXJfQW1iX2RlZ0MiLCAiVmFsdWUiOiAzNSwgIlVuaXQiOiAidGVtcGVyYXR1cmV+ZGVnQyJ9LCB7Ik5hbWUiOiAiVmFsdmU1UG9zRG1kIiwgIlZhbHVlIjogNTAsICJVbml0IjogImRpbWVuc2lvbmxlc3N+bm9uZSJ9LCB7Ik5hbWUiOiAidlZWX0V4dEFpckFtYkh1bWlkX3BjIiwgIlZhbHVlIjogMC4zLCAiVW5pdCI6ICJkaW1lbnNpb25sZXNzfm5vbmUifSwgeyJOYW1lIjogInZWVl9FeHRBaXJBbWJUZW1wX0MiLCAiVmFsdWUiOiA1MCwgIlVuaXQiOiAidGVtcGVyYXR1cmV+ZGVnQyJ9XX1dfSwgImFkZGl0aW9uYWxfc29mdHdhcmVfc3RhY2siOiB7IkV4YW1wbGV0b29sMSI6IHsibmFtZSI6ICJFeGFtcGxlVG9vbDEiLCAidmVyc2lvbiI6IDEuMCwgInBhdGgiOiAiSkZST0c6Ly9ob21lL0V4YW1wbGVUb29sMS8xLjAiLCAiYnVpbGRfc2NyaXB0IjogIkpGUk9HOi8vaG9tZS9FeGFtcGxlVG9vbDEvMS4wL2J1aWxkLnNoIiwgInBhcmFtZXRlcnMiOiBbeyJuYW1lIjogInBhcmFtMSIsICJ2YWx1ZSI6ICJ2YWx1ZTEifSwgeyJuYW1lIjogInBhcmFtMiIsICJ2YWx1ZSI6ICJ2YWx1ZTIifV19LCAiRXhhbXBsZXRvb2wyIjogeyJuYW1lIjogIkV4YW1wbGVUb29sMiIsICJ2ZXJzaW9uIjogMS4wLCAicGF0aCI6ICJKRlJPRzovL2hvbWUvRXhhbXBsZVRvb2wyLzEuMCIsICJidWlsZF9zY3JpcHQiOiAiSkZST0c6Ly9ob21lL0V4YW1wbGVUb29sMi8xLjAvYnVpbGQuc2giLCAicGFyYW1ldGVycyI6IFt7Im5hbWUiOiAicGFyYW0xIiwgInZhbHVlIjogInZhbHVlMSJ9LCB7Im5hbWUiOiAicGFyYW0yIiwgInZhbHVlIjogInZhbHVlMiJ9XX19LCAic3ltcGhvbnkiOiB7InRvb2xjaGFpbl9vdXRwdXRfcGF0aCI6ICIvYXBwL21udCIsICJhZ2VudCI6IHsicG9ydCI6IDgwOTh9LCAiYmFzZV91cmwiOiAiaHR0cDovLzE5Mi4xNjguMC43NSJ9fQ=="
config=$(echo $configEncoded | base64 -d)
#endregion Getting config from metamodel config yaml

#region parameters - get from config
echo "getting parameters from config"
resource_name_primary_prefix=$(echo $config | jq -r '.resource_name_primary_prefix')
resource_name_secondary_prefix=$(echo $config | jq -r '.resource_name_secondary_prefix')
resource_name_shared_short=$(echo $config | jq -r '.resource_name_shared_short')
resource_name_customer_short=$(echo $config | jq -r '.resource_name_customer_short')
customer_OEM_suffix=$(echo $config | jq -r '.customer_OEM_suffix')
project_name=$(echo $config | jq -r '.project_name')
environment_stage_short=$(echo $config | jq -r '.environment_stage_short')
project_description=$(echo $config | jq -r '.project_description')
subscription_id=$(echo $config | jq -r '.subscription_id')
echo "rg primary prefix is $resource_name_primary_prefix"
echo "rg secondary prefix is $resource_name_secondary_prefix"
echo "short is $resource_name_shared_short"
echo "customer oem is $customer_OEM_suffix"
echo "pj des short is $project_description"
echo "customer short is $resource_name_customer_short"
echo "pj is $project_name"
echo "env is $environment_stage_short"
echo "sub is $subscription_id"

#endregion parameters - get from config

#region Set the variables
echo "setting the variables"
SHARED_RESOURCE_GROUP="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_shared_short}-stamp-${environment_stage_short}-rg-001"
echo "setting rg $SHARED_RESOURCE_GROUP"
RESOURCE_GROUP="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-${environment_stage_short}-rg-001"
echo "setting dc $RESOURCE_GROUP"
DEV_CENTER_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-${environment_stage_short}-dc"
echo "setting env $DEV_CENTER_NAME"
ENVIRONMENT_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-p-${project_name}-vmss-001"
echo "setting pj $ENVIRONMENT_NAME"
PROJECT="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customer_OEM_suffix}-p-${project_name}-001"
echo "setting kv $PROJECT"
KEY_VAULT_NAME="${resource_name_primary_prefix}-${resource_name_secondary_prefix}-${resource_name_customer_short}-${customerOEMsuffix}-${environment_stage_short}-kv"
#endregion Set the variables 

#region Install Azure Dev Center extension
echo "Installing the Azure Dev Center extension"
clear_command_variables
command="az extension add --name devcenter --upgrade"
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Extension installation complete!"
#endregion Install Azure Dev Center extension

az configure --defaults group=

#region Get Role Id for the Subscription Owner
echo "Getting Role Id for the Subscription Owner"
clear_command_variables
command="az role definition list -n \"Owner\" --scope \"/subscriptions/$subscription_id\" --query [].name -o tsv"
commandGetOwnerRoleId_output=""
execute_command_exit_on_failure "$command" commandGetOwnerRoleId_output _command_status
echo "Got Subscritpion Owner Role ID: $commandGetOwnerRoleId_output"
#endregion Get Role Id for the Subscription Owner

az configure --defaults group=$RESOURCE_GROUP

#region Get Dev Center ID, Object ID
echo "Getting Azure Dev Center Resource ID"
clear_command_variables
command="az devcenter admin devcenter show -n \"$DEV_CENTER_NAME\" --query id -o tsv"
commandGetDevCenterId_output=""
execute_command_exit_on_failure "$command" commandGetDevCenterId_output _command_status
echo "Got Azure Dev Center Resource ID: $commandGetDevCenterId_output"

echo "Getting Azure Dev Center Object ID"
clear_command_variables
commandGetDevCenterObjId_output=""
command="az devcenter admin devcenter show -n \"$DEV_CENTER_NAME\" --query identity.principalId -o tsv"
execute_command_exit_on_failure "$command" commandGetDevCenterObjId_output _command_status
echo "Got Azure Dev Center Object ID: $commandGetDevCenterObjId_output"
#endregion Get Dev Center ID, Object ID

#region Get Managed Identity ID, Object ID
echo "Getting Managed Identity Resource ID"
clear_command_variables
command="az identity show --name \"$COMPUTE_GALLERY\" --resource-group \"$SHARED_RESOURCE_GROUP\" --query id -o tsv"
commandGetManagedIdentityId_output=""
execute_command_exit_on_failure "$command" commandGetManagedIdentityId_output _command_status
echo "Got Managed Identity Resource ID: $commandGetManagedIdentityId_output"

echo "Getting Managed Identity Object ID"
clear_command_variables
command="az resource show --ids \"$commandGetManagedIdentityId_output\" --query properties.principalId -o tsv"
commandGetManagedIdentityObjId_output=""
execute_command_exit_on_failure "$command" commandGetManagedIdentityObjId_output _command_status
echo "Got Managed Identity Object ID: $commandGetManagedIdentityObjId_output"
#endregion Get Managed Identity ID, Object ID

#region Create Project in Dev Center
echo "Creating Project in Azure Dev Center"
clear_command_variables
command="az devcenter admin project create -n \"$PROJECT\" --description \"$project_description\" --dev-center-id \"$commandGetDevCenterId_output\""
execute_command_exit_on_failure "$command" _command_output _command_status
#endregion Create Project in Dev Center

#region Assign Owner role to the Dev Center and Managed Identity, on the subscription
echo "Assigning Owner role to the Dev Center Object Id on the subscription"
clear_command_variables
command="az role assignment create --role \"Owner\" --assignee-object-id \"$commandGetDevCenterObjId_output\" --scope \"/subscriptions/$subscription_id\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Owner role to the Dev Center Object Id on the subscription"

echo "Assigning Owner role to the Managed Identity Object Id on the subscription"
clear_command_variables
command="az role assignment create --role \"Owner\" --assignee-object-id \"$commandGetManagedIdentityObjId_output\" --scope \"/subscriptions/$subscription_id\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Owner role to the Managed Identity Object Id on the subscription"
#endregion Assign Owner role to the Dev Center and Managed Identity, on the subscription

#region Create Environment Type for the Project, assign Contributor role on the subscription
echo "Creating Project Environment Type"
clear_command_variables
command="az devcenter admin project-environment-type create \
             -n \"$ENVIRONMENT_TYPE\" \
             --project \"$PROJECT\" \
             --identity-type \"SystemAssigned\" \
             --roles \"{\"${commandGetOwnerRoleId_output}\":{}}\" \
             --deployment-target-id \"/subscriptions/${subscription_id}\" \
             --status Enabled \
             --query 'identity.principalId' \
             --output tsv"
commandCreateProjectEnvType_output=""
execute_command_exit_on_failure "$command" commandCreateProjectEnvType_output _command_status
echo "Created Project Environment Type with Object ID: $commandCreateProjectEnvType_output"

echo "Assigning Contributor role to the Project Environment Type Object Id on the subscription"
clear_command_variables
command="az role assignment create --role \"Contributor\" --assignee-object-id $commandCreateProjectEnvType_output --scope \"/subscriptions/$subscription_id\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Contributor role to the Project Environment Type Object Id on the subscription"
#endregion Create Environment Type for the Project, assign Contributor role on the subscription

echo "Assigning Key Vault Secrets Officer role to the Project Environment Type Object Id on the subscription"
clear_command_variables
command="az role assignment create --role \"Key Vault Secrets Officer\" --assignee-object-id $commandCreateProjectEnvType_output --scope \"/subscriptions/$subscription_id/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Key Vault Secrets Officer role to the Project Environment Type Object Id on the subscription"
#endregion Create Environment Type for the Project, assign Contributor role on the subscription


#region Assign Dev Center Project Admin role, Deployment Environments User to MYOID
echo "Assigning Dev Center Project Admin role, Deployment Environments User to $MYOID"
clear_command_variables
command="az role assignment create --assignee \"$MYOID\" --role \"DevCenter Project Admin\" --scope \"/subscriptions/$subscription_id\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Dev Center Project Admin role to $MYOID"

echo "Assigning Deployment Environments User role to $MYOID"
clear_command_variables
command="az role assignment create --assignee \"$MYOID\" --role \"Deployment Environments User\" --scope \"/subscriptions/$subscription_id\""
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Assigned Deployment Environments User role to $MYOID"
#endregion Assign Dev Center Project Admin role, Deployment Environments User to MYOID

#region Create Dev Environment
echo "Creating Dev Environment"
clear_command_variables
command="az devcenter dev environment create \
            --environment-name \"$ENVIRONMENT_NAME\" \
            --environment-type \"$ENVIRONMENT_TYPE\" \
            --dev-center-name \"$DEV_CENTER_NAME\" \
            --project-name \"$PROJECT\" \
            --catalog-name \"$DEV_CENTER_CATALOG_NAME\" \
            --environment-definition-name \"$ENVIRONMENT_DEFINITION_NAME\" \
            --parameters '{\"customerOEMsuffix\":\"${customer_OEM_suffix}\",\"admin_username\":\"${ADMIN_USER}\",\"environmentStage\":\"${environment_stage_short}\",\"projectname\":\"${PROJECT}\"}'"
execute_command_exit_on_failure "$command" _command_output _command_status
echo "Created Dev Environment: $ENVIRONMENT_NAME"
#endregion Create Dev Environment

echo_output_dictionary_to_output_file
