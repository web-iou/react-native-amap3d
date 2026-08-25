import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";

export interface Spec extends TurboModule {
  initSDK(apiKey: string | null): void;
  getVersion(): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>("AMapSdk");
