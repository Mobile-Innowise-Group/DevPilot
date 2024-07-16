# Project modules
The created project consists of the following modules:
- Core
- Domain
- Data
- Core UI
- Navigation
- Features (optional)

### Core
Core module serves as a common dependency for all other project modules and has two main functions:
1. Contains elements common to the application (configuration, DI mechanism, application-level constants, localization keys, etc.), various extensions, and utilities.
2. Exports common or frequently used dependencies (e.g., `flutter_bloc` or `get_it`), eliminating the need to import them in each dependent module.
```
core/
├── lib/
│   └── src/
│       ├── config/
│       │   └── network
│       ├── constants
│       ├── di
│       ├── localization
│       ├── logger
│       └── utils
└── resources/
    └── lang
```
### Domain
Domain module describes the application's subject area, defining domain models and possible use cases. It also establishes the necessary interfaces for external dependencies, particularly for the data layer. In this case, the domain module includes the following categories of elements:
- Domain models
- Use-cases (atomic domain operations)
- Repository interfaces
- Domain exceptions
- DI setup for the domain layer
```
domain/
└── lib/
    └── src/
        ├── di
        ├── exceptions
        ├── models
        ├── repositories
        └── use_cases
```
### Data
Data module implements the interfaces defined in the domain module. It handles data operations and interacts with external APIs. In this case, it consists of the following categories of elements:
- Repository implementations
- Data providers, designed to interact with data sources and operate with entities
- Entities, dedicated models for data sources
- Mappers, converting domain models to entities and vice versa
- DI setup for the data layer
```
data/
└── lib/
    └── src/
        ├── di
        ├── entities
        ├── errors
        ├── mappers
        ├── providers
        └── repositories
```
### Core UI
Core UI defines common user interface elements for the entire application and includes:
- Application theme. This encompasses the colors and fonts used in the application, standard dimensions (such as default page padding or default animation duration), and images, icons, and animations
- Set of reusable widgets aligned with the application’s design, such as styled buttons or text fields
```
core_ui/
├── lib/
│   └── src/
│       ├── theme
│       └── widgets
└── resources/
    ├── fonts
    ├── images
    └── icons
```
### Navigation
Navigation module contains the application router configuration and provides the necessary DI for navigation.
```
navigation/
├── app_router
└── navigation_di
```
### Features
Features refers to a group of modules with a similar structure. Each of these modules implements a specific feature of the application (e.g., user login or order history). They relate to the presentation layer and perform operations in the domain by invoking the corresponding use cases.

# Dependency Graph
Below is the dependency graph of the described modules: