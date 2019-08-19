package storm.starter;
// Licensed under the Apache License, Version 2.0
// http://www.apache.org/licenses/LICENSE-2.0.html
//
// AUTOGENERATED BY H2O at 2015-09-24T18:17:10.430-07:00
// 3.3.0.99999
//
// Standalone prediction code with sample test data for GBMModel named GBMPojo
//
// How to download, compile and execute:
//     mkdir tmpdir
//     cd tmpdir
//     curl http://127.0.0.1:54321/3/h2o-genmodel.jar > h2o-genmodel.jar
//     curl http://127.0.0.1:54321/3/Models.java/GBMPojo > GBMPojo.java
//     javac -cp h2o-genmodel.jar -J-Xmx2g -J-XX:MaxPermSize=128m GBMPojo.java
//
//     (Note:  Try java argument -XX:+PrintCompilation to show runtime JIT compiler behavior.)
import java.util.Map;
import hex.genmodel.GenModel;
import hex.genmodel.annotations.ModelPojo;

@ModelPojo(name="GBMPojo", algorithm="gbm")
public class GBMPojo extends GenModel {
  public hex.ModelCategory getModelCategory() { return hex.ModelCategory.Binomial; }

  public boolean isSupervised() { return true; }
  public int nfeatures() { return 15; }
  public int nclasses() { return 2; }

  // Names of columns used by model.
  public static final String[] NAMES = NamesHolder_GBMPojo.VALUES;
  // Number of output classes included in training data response column.
  public static final int NCLASSES = 2;

  // Column domains. The last array contains domain of response column.
  public static final String[][] DOMAINS = new String[][] {
    /* Has4Legs */ null,
    /* CoatColor */ GBMPojo_ColInfo_1.VALUES,
    /* HairLength */ null,
    /* TailLength */ null,
    /* EnjoysPlay */ null,
    /* StaresOutWindow */ null,
    /* HoursSpentNapping */ null,
    /* RespondsToCommands */ null,
    /* EasilyFrightened */ null,
    /* Age */ null,
    /* Noise1 */ null,
    /* Noise2 */ null,
    /* Noise3 */ null,
    /* Noise4 */ null,
    /* Noise5 */ null,
    /* Label */ GBMPojo_ColInfo_15.VALUES
  };
  // Prior class distribution
  public static final double[] PRIOR_CLASS_DISTRIB = {0.327,0.673};
  // Class distribution used for model building
  public static final double[] MODEL_CLASS_DISTRIB = {0.327,0.673};

  public GBMPojo() { super(NAMES,DOMAINS); }
  public String getUUID() { return Long.toString(2942139837218643610L); }

  // Pass in data in a double[], pre-aligned to the Model's requirements.
  // Jam predictions into the preds[] array; preds[0] is reserved for the
  // main prediction (class for classifiers or value for regression),
  // and remaining columns hold a probability distribution for classifiers.
  public final double[] score0( double[] data, double[] preds ) {
    java.util.Arrays.fill(preds,0);
    double[] fdata = hex.genmodel.GenModel.SharedTree_clean(data);
    GBMPojo_Forest_0.score0(fdata,preds);
    GBMPojo_Forest_1.score0(fdata,preds);
    GBMPojo_Forest_2.score0(fdata,preds);
    GBMPojo_Forest_3.score0(fdata,preds);
    GBMPojo_Forest_4.score0(fdata,preds);
    GBMPojo_Forest_5.score0(fdata,preds);
    GBMPojo_Forest_6.score0(fdata,preds);
    GBMPojo_Forest_7.score0(fdata,preds);
    GBMPojo_Forest_8.score0(fdata,preds);
    GBMPojo_Forest_9.score0(fdata,preds);
    preds[2] = preds[1] + 0.7217851587474746;
    preds[2] = 1/(1+Math.min(1.0E19, Math.exp(-preds[2])));
    preds[1] = 1.0-preds[2];
    preds[0] = hex.genmodel.GenModel.getPrediction(preds, PRIOR_CLASS_DISTRIB, data, 0.5540730394375936);
    return preds;
  }
}
// The class representing training column names
class NamesHolder_GBMPojo implements java.io.Serializable {
  public static final String[] VALUES = new String[15];
  static {
    NamesHolder_GBMPojo_0.fill(VALUES);
  }
  static final class NamesHolder_GBMPojo_0 implements java.io.Serializable {
    static final void fill(String[] sa) {
      sa[0] = "Has4Legs";
      sa[1] = "CoatColor";
      sa[2] = "HairLength";
      sa[3] = "TailLength";
      sa[4] = "EnjoysPlay";
      sa[5] = "StaresOutWindow";
      sa[6] = "HoursSpentNapping";
      sa[7] = "RespondsToCommands";
      sa[8] = "EasilyFrightened";
      sa[9] = "Age";
      sa[10] = "Noise1";
      sa[11] = "Noise2";
      sa[12] = "Noise3";
      sa[13] = "Noise4";
      sa[14] = "Noise5";
    }
  }
}
// The class representing column CoatColor
class GBMPojo_ColInfo_1 implements java.io.Serializable {
  public static final String[] VALUES = new String[5];
  static {
    GBMPojo_ColInfo_1_0.fill(VALUES);
  }
  static final class GBMPojo_ColInfo_1_0 implements java.io.Serializable {
    static final void fill(String[] sa) {
      sa[0] = "Black";
      sa[1] = "Brown";
      sa[2] = "Grey";
      sa[3] = "Spotted";
      sa[4] = "White";
    }
  }
}
// The class representing column Label
class GBMPojo_ColInfo_15 implements java.io.Serializable {
  public static final String[] VALUES = new String[2];
  static {
    GBMPojo_ColInfo_15_0.fill(VALUES);
  }
  static final class GBMPojo_ColInfo_15_0 implements java.io.Serializable {
    static final void fill(String[] sa) {
      sa[0] = "cat";
      sa[1] = "dog";
    }
  }
}

class GBMPojo_Forest_0 {
  public static void score0(double[] fdata, double[] preds) {
    preds[1] += GBMPojo_Tree_0_class_0.score0(fdata);
  }
}
class GBMPojo_Tree_0_class_0 {
  static final double score0(double[] data) {
    double pred =  (data[6 /* HoursSpentNapping */] <2.5f
      ? (data[3 /* TailLength */] != 6.0f
        ? (!GenModel.bitSetContains(GRPSPLIT0, 0, (int) data[1 /* CoatColor */])
          ? 0.0880019f
          : (data[13 /* Noise4 */] <0.018522264f
            ? 0.11613135f
            : (data[9 /* Age */] != 9.0f ? 0.1485884f : 0.13235988f)))
        : 0.012268769f)
      : (data[3 /* TailLength */] <3.5f
        ? (data[7 /* RespondsToCommands */] <0.5f
          ? -0.22061062f
          : (!GenModel.bitSetContains(GRPSPLIT1, 0, (int) data[1 /* CoatColor */])
            ? -0.01664752f
            : (data[12 /* Noise3 */] <0.6257176f ? 0.1485884f : 0.10314853f)))
        : (data[2 /* HairLength */] <0.5f
          ? (data[7 /* RespondsToCommands */] <0.5f ? -0.3058104f : -0.01664752f)
          : (data[3 /* TailLength */] <5.5f
            ? (data[13 /* Noise4 */] <0.7780615f ? -0.27741045f : -0.16949075f)
            : -0.3058104f))));
    return pred;
  }
  // {01111000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT0 = new byte[] {30, 0, 0, 0};
  // {01110000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT1 = new byte[] {14, 0, 0, 0};
}

class GBMPojo_Forest_1 {
  public static void score0(double[] fdata, double[] preds) {
    preds[1] += GBMPojo_Tree_1_class_0.score0(fdata);
  }
}
class GBMPojo_Tree_1_class_0 {
  static final double score0(double[] data) {
    double pred =  (data[6 /* HoursSpentNapping */] <2.5f
      ? (data[3 /* TailLength */] != 6.0f
        ? (!GenModel.bitSetContains(GRPSPLIT0, 0, (int) data[1 /* CoatColor */])
          ? 0.08193019f
          : (data[3 /* TailLength */] <6.0f
            ? (data[13 /* Noise4 */] <0.018522264f ? 0.1432611f : 0.14191039f)
            : (data[5 /* StareOutWindow */] <0.5f ? 0.062075198f : 0.14195327f)))
        : 0.011091855f)
      : (data[3 /* TailLength */] <2.5f
        ? (data[12 /* Noise3 */] <0.48935533f ? 0.14267492f : 0.14855684f)
        : (data[2 /* HairLength */] <0.5f
          ? (data[7 /* RespondsToCommands */] <0.5f ? -0.22357261f : 0.026138676f)
          : (data[3 /* TailLength */] <5.5f
            ? (data[7 /* RespondsToCommands */] <0.5f ? -0.25129077f : -0.057499193f)
            : -0.25158477f))));
    return pred;
  }
  // {01111000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT0 = new byte[] {30, 0, 0, 0};
}

class GBMPojo_Forest_2 {
  public static void score0(double[] fdata, double[] preds) {
    preds[1] += GBMPojo_Tree_2_class_0.score0(fdata);
  }
}
class GBMPojo_Tree_2_class_0 {
  static final double score0(double[] data) {
    double pred =  (data[6 /* HoursSpentNapping */] <2.5f
      ? (data[3 /* TailLength */] != 6.0f
        ? (!GenModel.bitSetContains(GRPSPLIT0, 0, (int) data[1 /* CoatColor */])
          ? 0.07633824f
          : (data[13 /* Noise4 */] <0.018522264f
            ? 0.10180137f
            : (data[9 /* Age */] != 9.0f ? 0.13639407f : 0.11893812f)))
        : 0.010024107f)
      : (data[3 /* TailLength */] <2.5f
        ? (data[12 /* Noise3 */] <0.48935533f ? 0.13700679f : 0.14189592f)
        : (data[2 /* HairLength */] <0.5f
          ? (data[6 /* HoursSpentNapping */] != 5.0f
            ? (data[13 /* Noise4 */] <0.41936293f ? 0.10700112f : -0.068484366f)
            : -0.21035096f)
          : (data[3 /* TailLength */] <5.5f
            ? (data[7 /* RespondsToCommands */] <0.5f ? -0.21600579f : -0.05083163f)
            : -0.21786739f))));
    return pred;
  }
  // {01111000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT0 = new byte[] {30, 0, 0, 0};
}

class GBMPojo_Forest_3 {
  public static void score0(double[] fdata, double[] preds) {
    preds[1] += GBMPojo_Tree_3_class_0.score0(fdata);
  }
}
class GBMPojo_Tree_3_class_0 {
  static final double score0(double[] data) {
    double pred =  (data[6 /* HoursSpentNapping */] <2.5f
      ? (data[3 /* TailLength */] != 6.0f
        ? (!GenModel.bitSetContains(GRPSPLIT0, 0, (int) data[1 /* CoatColor */])
          ? 0.07114688f
          : (data[3 /* TailLength */] <6.0f
            ? (data[13 /* Noise4 */] <0.018522264f ? 0.13385855f : 0.13175501f)
            : (data[5 /* StaresOutWindow */] <0.5f ? 0.0474084f : 0.13182291f)))
        : 0.009055963f)
      : (data[3 /* TailLength */] <3.5f
        ? (data[7 /* RespondsToCommands */] <0.5f
          ? -0.14263228f
          : (!GenModel.bitSetContains(GRPSPLIT1, 0, (int) data[1 /* CoatColor */])
            ? -0.02360882f
            : (data[9 /* Age */] <16.5f ? 0.13695288f : 0.08952194f)))
        : (data[8 /* EasilyFrightened */] <0.5f
          ? (data[7 /* RespondsToCommands */] <0.5f
            ? (data[10 /* Noise1 */] <0.3829831f ? -0.2004312f : -0.19511971f)
            : -0.038507923f)
          : (data[5 /* StaresOutWindow */] <0.5f
            ? -0.14426081f
            : (data[9 /* Age */] != 2.0f ? -0.19771059f : -0.16344947f)))));
    return pred;
  }
  // {01111000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT0 = new byte[] {30, 0, 0, 0};
  // {01110000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT1 = new byte[] {14, 0, 0, 0};
}

class GBMPojo_Forest_4 {
  public static void score0(double[] fdata, double[] preds) {
    preds[1] += GBMPojo_Tree_4_class_0.score0(fdata);
  }
}
class GBMPojo_Tree_4_class_0 {
  static final double score0(double[] data) {
    double pred =  (data[6 /* HoursSpentNapping */] <2.5f
      ? (data[3 /* TailLength */] != 6.0f
        ? (!GenModel.bitSetContains(GRPSPLIT0, 0, (int) data[1 /* CoatColor */])
          ? 0.0662977f
          : (data[13 /* Noise4 */] <0.018522264f
            ? 0.08978581f
            : (data[9 /* Age */] != 9.0f ? 0.12788714f : 0.108413726f)))
        : 0.008178662f)
      : (data[3 /* TailLength */] <2.5f
        ? (data[12 /* Noise3 */] <0.48935533f ? 0.1292353f : 0.13667698f)
        : (data[2 /* HairLength */] <0.5f
          ? (data[6 /* HoursSpentNapping */] <4.0f
            ? 0.08030756f
            : (data[7 /* RespondsToCommands */] <0.5f ? -0.18313786f : -0.063593574f))
          : (data[8 /* EasilyFrightened */] <0.5f
            ? (data[3 /* TailLength */] <5.5f ? -0.0124595985f : -0.18165442f)
            : (!GenModel.bitSetContains(GRPSPLIT1, 0, (int) data[1 /* CoatColor */]) ? -0.18188241f : -0.16656914f)))));
    return pred;
  }
  // {01111000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT0 = new byte[] {30, 0, 0, 0};
  // {01100000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT1 = new byte[] {6, 0, 0, 0};
}

class GBMPojo_Forest_5 {
  public static void score0(double[] fdata, double[] preds) {
    preds[1] += GBMPojo_Tree_5_class_0.score0(fdata);
  }
}
class GBMPojo_Tree_5_class_0 {
  static final double score0(double[] data) {
    double pred =  (data[6 /* HoursSpentNapping */] <2.5f
      ? (data[3 /* TailLength */] != 6.0f
        ? (data[3 /* TailLength */] <6.0f
          ? (data[9 /* Age */] != 16.0f
            ? (!GenModel.bitSetContains(GRPSPLIT0, 0, (int) data[1 /* CoatColor */]) ? 0.124584004f : 0.13310453f)
            : (data[10 /* Noise1 */] <0.39800626f ? 0.06326525f : 0.12445538f))
          : (data[13 /* Noise4 */] <0.13918766f
            ? 0.0048794686f
            : (data[14 /* Noise5 */] <0.86246866f ? 0.12581825f : 0.06367652f)))
        : 0.0073841065f)
      : (data[3 /* TailLength */] <2.5f
        ? (data[12 /* Noise3 */] <0.48935533f ? 0.12570466f : 0.13208064f)
        : (data[2 /* HairLength */] <0.5f
          ? (data[7 /* RespondsToCommands */] <0.5f ? -0.15073587f : 0.029354105f)
          : (data[8 /* EasilyFrightened */] <0.5f
            ? (data[3 /* TailLength */] <5.5f ? -0.011197025f : -0.16812283f)
            : (!GenModel.bitSetContains(GRPSPLIT1, 0, (int) data[1 /* CoatColor */]) ? -0.16843282f : -0.15377346f)))));
    return pred;
  }
  // {10000000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT0 = new byte[] {1, 0, 0, 0};
  // {01100000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT1 = new byte[] {6, 0, 0, 0};
}

class GBMPojo_Forest_6 {
  public static void score0(double[] fdata, double[] preds) {
    preds[1] += GBMPojo_Tree_6_class_0.score0(fdata);
  }
}
class GBMPojo_Tree_6_class_0 {
  static final double score0(double[] data) {
    double pred =  (data[6 /* HoursSpentNapping */] <2.5f
      ? (data[7 /* RespondsToCommands */] <0.5f
        ? (!GenModel.bitSetContains(GRPSPLIT0, 0, (int) data[1 /* CoatColor */])
          ? -0.08568321f
          : (data[11 /* Noise2 */] <0.24012282f
            ? 0.059644982f
            : (data[12 /* Noise3 */] <0.24789679f ? 0.12822971f : 0.12180561f)))
        : (data[13 /* Noise4 */] <0.02046848f
          ? 0.07639909f
          : (!GenModel.bitSetContains(GRPSPLIT1, 0, (int) data[1 /* CoatColor */])
            ? (data[9 /* Age */] != 9.0f ? 0.12209322f : 0.096696936f)
            : 0.12899657f)))
      : (data[3 /* TailLength */] <3.5f
        ? (!GenModel.bitSetContains(GRPSPLIT2, 0, (int) data[1 /* CoatColor */])
          ? (data[7 /* RespondsToCommands */] <0.5f ? -0.1673429f : 0.01188363f)
          : (data[10 /* Noise1 */] <0.5228332f ? 0.12843634f : 0.14245284f))
        : (data[8 /* EasilyFrightened */] <0.5f
          ? (data[7 /* RespondsToCommands */] <0.5f
            ? (data[6 /* HoursSpentNapping */] != 5.0f ? -0.16521677f : -0.15657602f)
            : -0.017920874f)
          : (data[5 /* StaresOutWindow */] <0.5f
            ? -0.109569974f
            : (data[2 /* HairLength */] <0.5f ? -0.18520229f : -0.15443023f)))));
    return pred;
  }
  // {01110000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT0 = new byte[] {14, 0, 0, 0};
  // {10000000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT1 = new byte[] {1, 0, 0, 0};
  // {01100000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT2 = new byte[] {6, 0, 0, 0};
}

class GBMPojo_Forest_7 {
  public static void score0(double[] fdata, double[] preds) {
    preds[1] += GBMPojo_Tree_7_class_0.score0(fdata);
  }
}
class GBMPojo_Tree_7_class_0 {
  static final double score0(double[] data) {
    double pred =  (data[6 /* HoursSpentNapping */] <2.5f
      ? (data[3 /* TailLength */] != 6.0f
        ? (!GenModel.bitSetContains(GRPSPLIT0, 0, (int) data[1 /* CoatColor */])
          ? 0.04761952f
          : (data[3 /* TailLength */] <6.0f
            ? (data[13 /* Noise4 */] <0.018522264f ? 0.122064196f : 0.11927856f)
            : (data[5 /* StaresOutWindow */] <0.5f ? 0.0151380105f : 0.11992228f)))
        : -6.6823204E-4f)
      : (data[3 /* TailLength */] <2.5f
        ? (!GenModel.bitSetContains(GRPSPLIT1, 0, (int) data[1 /* CoatColor */]) ? 0.121530764f : 0.12643112f)
        : (data[2 /* HairLength */] <0.5f
          ? (data[6 /* HoursSpentNapping */] <4.0f
            ? 0.07966291f
            : (data[12 /* Noise3 */] <0.41605228f ? -0.033159655f : -0.16096914f))
          : (data[3 /* TailLength */] <5.5f
            ? (data[8 /* EasilyFrightened */] <0.5f ? -0.0044470425f : -0.13902695f)
            : (data[8 /* EasilyFrightened */] <0.5f ? -0.15167564f : -0.14766087f)))));
    return pred;
  }
  // {01111000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT0 = new byte[] {30, 0, 0, 0};
  // {00101000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT1 = new byte[] {20, 0, 0, 0};
}

class GBMPojo_Forest_8 {
  public static void score0(double[] fdata, double[] preds) {
    preds[1] += GBMPojo_Tree_8_class_0.score0(fdata);
  }
}
class GBMPojo_Tree_8_class_0 {
  static final double score0(double[] data) {
    double pred =  (data[6 /* HoursSpentNapping */] <2.5f
      ? (data[3 /* TailLength */] != 6.0f
        ? (!GenModel.bitSetContains(GRPSPLIT0, 0, (int) data[1 /* CoatColor */])
          ? 0.044122998f
          : (data[13 /* Noise4 */] <0.018522264f
            ? 0.069646195f
            : (data[9 /* Age */] != 9.0f ? 0.11718993f : 0.091819294f)))
        : -6.0123525E-4f)
      : (data[3 /* TailLength */] <2.5f
        ? (!GenModel.bitSetContains(GRPSPLIT1, 0, (int) data[1 /* CoatColor */]) ? 0.119096816f : 0.12332848f)
        : (data[2 /* HairLength */] <0.5f
          ? (data[7 /* RespondsToCommands */] <0.5f ? -0.12763098f : 0.033691287f)
          : (data[3 /* TailLength */] <5.5f
            ? (data[7 /* RespondsToCommands */] <0.5f ? -0.13796118f : -0.013975056f)
            : (data[5 /* StaresOutWindow */] <0.5f ? -0.14589271f : -0.14130971f)))));
    return pred;
  }
  // {01111000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT0 = new byte[] {30, 0, 0, 0};
  // {00101000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT1 = new byte[] {20, 0, 0, 0};
}

class GBMPojo_Forest_9 {
  public static void score0(double[] fdata, double[] preds) {
    preds[1] += GBMPojo_Tree_9_class_0.score0(fdata);
  }
}
class GBMPojo_Tree_9_class_0 {
  static final double score0(double[] data) {
    double pred =  (data[6 /* HoursSpentNapping */] <2.5f
      ? (data[7 /* RespondsToCommands */] <0.5f
        ? (data[3 /* TailLength */] <4.5f
          ? (!GenModel.bitSetContains(GRPSPLIT0, 0, (int) data[1 /* CoatColor */])
            ? (data[9 /* Age */] <4.5f ? 0.11507189f : 0.115601234f)
            : 0.117520146f)
          : -0.068641685f)
        : (!GenModel.bitSetContains(GRPSPLIT1, 0, (int) data[1 /* CoatColor */])
          ? (data[3 /* TailLength */] <6.5f
            ? (data[3 /* TailLength */] <4.5f ? 0.11524487f : 0.11898457f)
            : (data[5 /* StaresOutWindow */] <0.5f ? 0.0033368843f : 0.11584385f))
          : 0.12325309f))
      : (data[3 /* TailLength */] <3.5f
        ? (!GenModel.bitSetContains(GRPSPLIT2, 0, (int) data[1 /* CoatColor */])
          ? (data[7 /* RespondsToCommands */] <0.5f ? -0.14521906f : 0.0061618523f)
          : (data[10 /* Noise1 */] <0.5228332f ? 0.12177707f : 0.13905832f))
        : (data[5 /* StaresOutWindow */] <0.5f
          ? -0.053777825f
          : (data[8 /* EasilyFrightened */] <0.5f
            ? (data[7 /* RespondsToCommands */] <0.5f ? -0.14158723f : -0.020394998f)
            : (data[2 /* HairLength */] <0.5f ? -0.16268094f : -0.13421829f)))));
    return pred;
  }
  // {10101000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT0 = new byte[] {21, 0, 0, 0};
  // {10000000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT1 = new byte[] {1, 0, 0, 0};
  // {01100000 00000000 00000000 00000000}
  public static final byte[] GRPSPLIT2 = new byte[] {6, 0, 0, 0};
}


