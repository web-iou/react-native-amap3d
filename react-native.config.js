module.exports = {
  dependency: {
    platforms: {
      ios: {
        podspecPath: "react-native-amap3d.podspec",
      },
      android: {
        sourceDir: "lib/android",
        packageImportPath: "import qiuxiang.amap3d.AMap3DPackage;",
        packageInstance: "new AMap3DPackage()",
      },
    },
  },
};
