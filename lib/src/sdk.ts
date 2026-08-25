import AMapSdk from "./specs/NativeAMapSdk";

export function init(apiKey?: string) {
  AMapSdk.initSDK(apiKey ?? null);
}

export function getVersion(): Promise<string> {
  return AMapSdk.getVersion();
}
