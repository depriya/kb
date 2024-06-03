_Copyright (C) Microsoft Corporation_

# ADR: Extension Discovery in Toolchain Metadata Services

- Status: accepted
- Last Updated: 2024-03-19

## Table of Contents

<!-- toc -->
1. [Context and Problem Statement](#context-and-problem-statement)
1. [Decision Drivers](#decision-drivers)
1. [Considered Options](#considered-options)
1. [Decision Outcome](#decision-outcome)
1. [Pros and Cons of the Options](#pros-and-cons-of-the-options)
    1. [option 1 - Static location within the Toolchain Metadata Services project](#option-1---static-location-within-the-toolchain-metadata-services-project)
    1. [option 2 - Local-only repository](#option-2---local-only-repository)
    1. [option 3 - Provider interface](#option-3---provider-interface)
1. [Links](#links)
<!-- tocstop -->


## Context and Problem Statement

Components of Toolchain Metadata Services are meant to be easily extensible. Users should be able to define their own extensions and store those definitions wherever makes sense for their project. For this to work, we need a solution for extension discovery.

## Decision Drivers

1. Relocatable extensions.
    1. Extensions should be relocatable. They should not be tied to a specific location.
1. Custom implementations.
    1. Extensions should be discoverable from a local, or a remote repository.
    1. There may be other mechanisms to discover extensions that the user would want to implement. Therefore, there needs to be an abstraction to enable introduction of custom implementations.
1. Self-contained scenarios. Encapsulation.
    1. A scenario for the Toolchain should be self-contained and not require any additional implementation.
    1. The metamodel and the extensions to work with it should be sufficient to build and run a scenario and should be included into the scenario completely, or be referenced from the scenario. For example, a Virtual ECU Builder scenario should contain the metamodel and reference all necessary and sufficient extensions to build and run a Virtual ECU.

## Considered Options

1. Static location within the Toolchain Metadata Services project.
1. Local-only repository.
1. Provider interface.

## Decision Outcome

Chosen option: "Provider interface", because it is the only option that meets the criteria outlined in [Decision Drivers](#decision-drivers) section.


## Pros and Cons of the Options

### option 1 - Static location within the Toolchain Metadata Services project

That was the initial implementation of the Toolchain Metadata Services CLI Tool.

#### Pros

- Easy to follow.
- The simplest implementation.

#### Cons

- Not flexible enough to meet the requirements outlined in [Decision Drivers](#decision-drivers) section.

### option 2 - Local-only repository

Local-only repository is a location on a local file system where the Toolchain Metadata Services will look for extensions. The location can be specified in the configuration file.

#### Pros

- Relatively simple to implement and follow.
- Meets the "Reloctable extensions" and "Encapsulation" criteria from the [Decision Drivers](#decision-drivers) section.
    - Extensions can be placed in a folder that is not part of the Toolchain Metadata Services project.
    - Extensions can be placed in a folder that describes the scenario and contains the metamodel for the scenario.

#### Cons

- Does not meet "Custom implementations" criteria from the [Decision Drivers](#decision-drivers) section.
    - The implementation works for a repository on a local file system only.
    - There is no abstraction to enable introduction of custom implementations.

### option 3 - Provider interface

The Provider interface is an abstraction that enables the introduction of custom implementations for discovering extensions for Toolchain Metadata Services. The interface is defined in the Toolchain Metadata Services project. A metamodel can reference one or more specific providers that implement the Provider interface. The Toolchain Metadata Services will use these providers to discover extensions.

[Symphony](https://github.com/eclipse-symphony/symphony/blob/main/docs/symphony-book/campaign-management/campaign.md#stage-interface) uses a similar approach to work with stages of a campaign.

#### Pros

- Meets all criteria from the [Decision Drivers](#decision-drivers) section.

#### Cons

- The abstraction introduces a level of indirection separating the extension discovery mechanism from the actual implementation.


## Links

- [Symphony target provider documentation](https://github.com/eclipse-symphony/symphony/blob/main/docs/symphony-book/providers/target_provider.md).
- [Toolchain Metadata Services documentation](../../../toolchain/doc/README.md).
- [Design specification for Toolchain Metadata Services - Extension Discovery](../../../toolchain/doc/design/README.md#extension-discovery).
- [vECU Builder Guide](../../../../scenarios/vecu_builder_guide/README.md).
