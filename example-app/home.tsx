import { useNavigation, useTheme } from "@react-navigation/native";
import * as React from "react";
import {
  Platform,
  ScrollView,
  StyleSheet,
  Text,
  TouchableNativeFeedback,
  TouchableOpacity,
  View,
} from "react-native";
import { AMapSdk } from "react-native-amap3d";
import screens from "./screens";
import { NavigationProps, ScreenName } from "./types";

export default () => {
  const navigation = useNavigation<NavigationProps>();
  React.useEffect(() => {
    AMapSdk.init(
      Platform.select({
        android: "c52c7169e6df23490e3114330098aaac",
        ios: "186d3464209b74effa4d8391f441f14d",
      })
    );
    AMapSdk.getVersion().then((version) => {
      navigation.setOptions({ headerRight: () => <Text>v{version}</Text> });
    });
  }, []);
  return (
    <ScrollView>
      {Object.keys(screens).map((i) => (
        <Item key={i} name={i as keyof typeof screens} />
      ))}
    </ScrollView>
  );
};

function Item({ name }: { name: ScreenName }) {
  const { colors } = useTheme();
  const navigation = useNavigation<NavigationProps>();
  const content = (
    <View style={style.item}>
      <Text style={[style.itemText, { color: colors.text }]}>{name}</Text>
    </View>
  );
  const onPress = () => navigation.push(name);
  return Platform.OS === "android" ? (
    <TouchableNativeFeedback onPress={onPress}>{content}</TouchableNativeFeedback>
  ) : (
    <TouchableOpacity onPress={onPress}>{content}</TouchableOpacity>
  );
}

const style = StyleSheet.create({
  item: { padding: 16 },
  itemText: { fontSize: 16 },
});
