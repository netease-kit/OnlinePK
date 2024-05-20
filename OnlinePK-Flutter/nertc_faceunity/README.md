# nertc_faceunity

- 

#### Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✔️    | ✔️  |       |   |       |         |



# Usage

Add a dependency on the `nertc_core` and `nertc_faceunity` package in the `dependencies`

## Step 1 

Configure the corresponding key and certificate. The certificate needs to be provided by the company's Xiangxin Technology

## Step 2

Initialize the beauty engine and fill in the corresponding parameters and certificates. The following is a code example

```dart
import 'package:nertc_faceunity/nertc_faceunity.dart';

void main() {
   var _beautyEngine = NERtcFaceUnityEngine();
  _beautyEngine.create(beautyKey: Uint8List.fromList(Config.auth)
}
```

## Step 3

For the currently supported interface capabilities, please refer to the example and notes for the scope

```dart
await _beautyEngine.setFilterName(beautyParams.filterName);
await _beautyEngine.setFilterLevel( beautyParams.filterLevel);
await _beautyEngine.setColorLevel( beautyParams.colorLevel);
await _beautyEngine.setRedLevel(beautyParams.redLevel);
await _beautyEngine.setBlurLevel(beautyParams.blurLevel);
await _beautyEngine.setEyeBright(beautyParams.eyeBright);
await _beautyEngine.setCheekThinning(beautyParams.cheekThinning);
await _beautyEngine.setEyeEnlarging(beautyParams.eyeEnlarging);
```

## Step 4

If you want to support multiple parameters, you can refer to the following code method.

Resetting complex  beauty parameters can be implemented relatively simply

```
 var _faceUnityParams = NEFaceUnityParams();
_beautyEngine.setMultiFUParams(_faceUnityParams);
```

## Other

Supported types of current filter parameters

```
const filterNames = [origin,bailiang1,bailiang2,bailiang3,bailiang4,bailiang5,bailiang6,bailiang7,
  fennen1,fennen2,fennen3,fennen4,fennen5,fennen6,fennen7,fennen8,
  gexing1,gexing2,gexing3,gexing4,gexing5,gexing6,gexing7,gexing8,gexing9,gexing10,
  heibai1,heibai2,heibai3,heibai5,
  lengsediao1,lengsediao2,lengsediao3,lengsediao4,lengsediao5,lengsediao6,lengsediao7,lengsediao8,lengsediao9,lengsediao10,lengsediao11,
  nuansediao1,nuansediao2,nuansediao3,gexing11,
];
```
