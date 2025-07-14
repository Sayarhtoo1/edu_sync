# Caching Implementation Plan

## Caching Strategy

A "cache-aside" strategy will be implemented. When the app needs data, it will:

1.  **Check the local `floor` database (the cache) first.**
2.  If the data is in the cache and is recent enough, it will be displayed immediately.
3.  If the data is not in the cache or is stale, the app will fetch it from the Supabase backend.
4.  Once the data is fetched from Supabase, it will be stored in the local `floor` database for future use.

## Plan of Action

1.  **Define Cacheable Data:** The first step is to decide what data to cache. The initial suggestion is to cache **announcements** and **school classes**. This can be expanded to other data like lesson plans or user profiles.

2.  **Create Cache-Specific Models:** New Dart model classes (entities) will be created for the data to be cached. These models will be annotated for use with the `floor` database.

3.  **Create Data Access Objects (DAOs):** For each type of cached data, a DAO will be created. This class will provide methods to insert, retrieve, and delete data from the `floor` database.

4.  **Update the Database Definition:** The existing `AppDatabase` class (in `lib/database.dart`) will be updated to include the new cache entities and DAOs.

5.  **Build a `CacheService`:** A central `CacheService` will be created to manage the caching logic. This service will be responsible for fetching data from the cache or the network and determining if the cached data is still valid.

6.  **Integrate Caching into the UI:** The UI code (screens and widgets) will be modified to use the `CacheService`. Instead of fetching data directly from Supabase, they will now go through the `CacheService`.

7.  **Add `cached_network_image`:** The `cached_network_image` package will be added to `pubspec.yaml` to handle caching of network images.
