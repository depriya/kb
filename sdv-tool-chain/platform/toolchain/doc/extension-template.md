_Copyright (C) Microsoft Corporation_

# Extension Template

An extension template is a text file in the `./templates` folder of the extension. See [toolchain/src/extension/metamodel/mock/deploy_local/templates/mock_deploy_local.sh.j2](../src/extension/metamodel/mock/deploy_local/templates/mock_deploy_local.sh.j2) for the example of a template. Two types of text files are supported in the `./templates` folder: a [Jinja2 template](#jinja2-template) and a [Regular file](#regular-file).

## Jinja2 template

Jinja2 templating language was chosen to parametrize extensions because of its vast capabilities and flexibility. [Flask](https://flask.palletsprojects.com/en/2.3.x/templating/), a web-framework in Python, uses Jinja2 as its template language.

A Jinja2 template is a text file with the `.j2` extension. The tempalte file may contain any number of Jinja2 expressions. See [Jinja2 documentation](https://palletsprojects.com/p/jinja/) for the details. When a component of the Toolchain Metadata Services executes an extension with a Jinja2 template, the template is processed, and the file with the same filename, but without the `.j2` extension, is written to the output location. A file of that type can use capabilities of Jinja2. For example, the following statement references a parameter from the metamodel:

```
"useExistingVNet": "{{ parameters.use_existing_vnet|string|lower }}"
```

Note that [Jinja2 filters](https://jinja.palletsprojects.com/en/3.1.x/templates/#filters) can be also used to transform the output, like in the above example `|string`, and `|lower`.

Conditional logic, cycles, and other types of logic can be used. The following is an example of conditional logic:

```
{% if parameters.use_existing_vnet %}
    "virtualNetworkResourceGroupName": "{{parameters.virtual_network_resource_group_name}}",
{% else %}
    "networkSecurityGroupRules": [],
    "addressPrefixes": [],
    "subnets": [],
{% endif %}
```

## Regular File

A file that does not end with the `.j2` extension is a regular file and will be copied to the output location as is when the extension is executed.
