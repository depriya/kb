set AVLAST_HOME=C:\Program Files (x86)\AVL\R2022.2


"C:\Program Files (x86)\AVL\R2022.2\user_python\python3\python.exe" {% for software in
parameters.input_parameter.additional_software_stack if software.Script == 'build_model_connect_project' -%}
{%- set path = software.FilePath -%}
{{ path }}
{%- endfor %} ^
--generateSilProject ^
--targetProjectName {{ parameters.input_parameter.project_config.project_name }}.proj ^
{%- for lib_key, lib_value in parameters.input_parameter.model_stack.ModulesLibrary.items() -%}
{%- set paramType = '--SubSys' -%}
{%- set module_library_yml = 'Module_Library.yml' -%}
{%- set prefix = paramType ~ ' ' ~ module_library_yml -%}
{%- for blockitem in lib_value -%}
{%- set blockPrefix = prefix ~ ':' ~blockitem.BlockName -%}
{%- for subsys in blockitem.SubSys -%}
{%- set subsysPrefix = blockPrefix ~ ':' ~ subsys.Name -%}
{%- for subSysParam in subsys.SubSysParam if subSysParam %}
{{ subsysPrefix }}:{{subSysParam.Param}} ^
{%- else %}
{{ subsysPrefix }} ^
{%- endfor %}
{%- endfor -%}
{%- endfor -%}
{%- endfor %}
--SimStartTime 0 ^
--SimEndTime 100 ^
--SimTimeStep 0.005
pause