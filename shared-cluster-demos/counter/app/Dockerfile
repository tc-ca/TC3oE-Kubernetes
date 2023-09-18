# https://docs.microsoft.com/en-us/dotnet/core/docker/build-container?tabs=linux
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app

# Copy everything
COPY ./app ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build-env /app/out .

USER 1001
ENV ASPNETCORE_URLS http://+:8000
EXPOSE 8000

# Fix issue with read-only file system
# > Failed to create CoreCLR, HRESULT: 0x80004005
# https://github.com/dotnet/runtime/issues/46093#issuecomment-873351388
ENV COMPlus_EnableDiagnostics=0


ENTRYPOINT ["dotnet", "app.dll"]