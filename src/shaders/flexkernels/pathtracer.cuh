#pragma once
#define Matrix SlangMatrix
#include "slang-cuda-prelude.h"

static __device__ float3  min_0(float3  x_0, float3  y_0)
{
    float3  result_0;
    int i_0 = int(0);
    for(;;)
    {
        if(i_0 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_0, i_0) = (F32_min((_slang_vector_get_element(x_0, i_0)), (_slang_vector_get_element(y_0, i_0))));
        i_0 = i_0 + int(1);
    }
    return result_0;
}

__device__ static const FixedArray<float, 4>  HAIR_TILTS_0 = { {
    -2.0f, 1.0f, 4.0f, 0.0f
} };
__device__ static const FixedArray<float, 4>  HAIR_WIDTHS_0 = { {
    1.0f, 0.5f, 2.0f, 2.0f
} };
static __device__ float3  exp_0(float3  x_1)
{
    float3  result_1;
    int i_1 = int(0);
    for(;;)
    {
        if(i_1 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_1, i_1) = (F32_exp((_slang_vector_get_element(x_1, i_1))));
        i_1 = i_1 + int(1);
    }
    return result_1;
}

static __device__ float3  log_0(float3  x_2)
{
    float3  result_2;
    int i_2 = int(0);
    for(;;)
    {
        if(i_2 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_2, i_2) = (F32_log((_slang_vector_get_element(x_2, i_2))));
        i_2 = i_2 + int(1);
    }
    return result_2;
}

static __device__ float3  max_0(float3  x_3, float3  y_1)
{
    float3  result_3;
    int i_3 = int(0);
    for(;;)
    {
        if(i_3 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_3, i_3) = (F32_max((_slang_vector_get_element(x_3, i_3)), (_slang_vector_get_element(y_1, i_3))));
        i_3 = i_3 + int(1);
    }
    return result_3;
}

static __device__ float dot_0(float3  x_4, float3  y_2)
{
    return x_4.x * y_2.x + x_4.y * y_2.y + x_4.z * y_2.z;
}

static __device__ float3  reflect_0(float3  i_4, float3  n_0)
{
    return i_4 - make_float3 (2.0f * dot_0(n_0, i_4)) * n_0;
}

static __device__ float3  refract_0(float3  i_5, float3  n_1, float eta_0)
{
    float _S1 = dot_0(n_1, i_5);
    float _S2 = 1.0f - eta_0 * eta_0 * (1.0f - _S1 * _S1);
    if(_S2 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S1 + (F32_sqrt((_S2)))) * n_1;
}

__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
static __device__ float3  clamp_0(float3  x_5, float3  minBound_0, float3  maxBound_0)
{
    return min_0(max_0(x_5, minBound_0), maxBound_0);
}

static __device__ float3  tan_0(float3  x_6)
{
    float3  result_4;
    int i_6 = int(0);
    for(;;)
    {
        if(i_6 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_4, i_6) = (F32_tan((_slang_vector_get_element(x_6, i_6))));
        i_6 = i_6 + int(1);
    }
    return result_4;
}

static __device__ float3  acos_0(float3  x_7)
{
    float3  result_5;
    int i_7 = int(0);
    for(;;)
    {
        if(i_7 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_5, i_7) = (F32_acos((_slang_vector_get_element(x_7, i_7))));
        i_7 = i_7 + int(1);
    }
    return result_5;
}

static __device__ float3  abs_0(float3  x_8)
{
    float3  result_6;
    int i_8 = int(0);
    for(;;)
    {
        if(i_8 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_6, i_8) = (F32_abs((_slang_vector_get_element(x_8, i_8))));
        i_8 = i_8 + int(1);
    }
    return result_6;
}

static __device__ float length_0(float3  x_9)
{
    return (F32_sqrt((dot_0(x_9, x_9))));
}

static __device__ float distance_0(float3  x_10, float3  y_3)
{
    return length_0(x_10 - y_3);
}

static __device__ float3  mul_0(float3  left_0, Matrix<float, 3, 3>  right_0)
{
    float3  result_7;
    int j_0 = int(0);
    for(;;)
    {
        if(j_0 < int(3))
        {
        }
        else
        {
            break;
        }
        int i_9 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_9 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_0, i_9) * _slang_vector_get_element(right_0.rows[i_9], j_0);
            i_9 = i_9 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_7, j_0) = sum_0;
        j_0 = j_0 + int(1);
    }
    return result_7;
}

static __device__ float3  cross_0(float3  left_1, float3  right_1)
{
    float _S3 = left_1.y;
    float _S4 = right_1.z;
    float _S5 = left_1.z;
    float _S6 = right_1.y;
    float _S7 = right_1.x;
    float _S8 = left_1.x;
    return make_float3 (_S3 * _S4 - _S5 * _S6, _S5 * _S7 - _S8 * _S4, _S8 * _S6 - _S3 * _S7);
}

static __device__ float clamp_1(float x_11, float minBound_1, float maxBound_1)
{
    return (F32_min(((F32_max((x_11), (minBound_1)))), (maxBound_1)));
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ uint hash(uint x_12)
{
    uint _S9 = x_12 * 747796405U + 2891336453U;
    uint _S10 = ((_S9 >> ((_S9 >> 28U) + 4U)) ^ _S9) * 277803737U;
    return (_S10 >> 22U) ^ _S10;
}

struct Random
{
    uint state;
    float value;
};

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S11;
    (&_S11)->state = state_0;
    (&_S11)->value = value_0;
    return _S11;
}

__device__ Random pcg(uint state_1)
{
    uint _S12 = hash(state_1);
    float value_1 = float(_S12 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S12, value_1);
}

__device__ Random normal_distribution(uint state_2)
{
    Random _S13 = pcg(state_2);
    Random _S14 = pcg(_S13.state);
    float _S15 = 6.28318548202514648f * _S13.value;
    float _S16 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S14.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S14.state, _S16 * (F32_cos((_S15))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_3, float3  value_2)
{
    RandomSphere _S17;
    (&_S17)->state = state_3;
    (&_S17)->value = value_2;
    return _S17;
}

__device__ RandomSphere random_sphere(uint state_4)
{
    Random _S18 = normal_distribution(state_4);
    Random _S19 = normal_distribution(_S18.state);
    Random _S20 = normal_distribution(_S19.state);
    float3  _S21 = make_float3 (_S18.value, _S19.value, _S20.value);
    float3  _S22 = ((((_S21)) * make_float3(rnorm3df(((_S21)).x, ((_S21)).y, ((_S21)).z))));
    return RandomSphere_x24init_0(_S20.state, _S22);
}

__device__ float trowbridgeReitz(float alpha_0, float n_dot_h_0)
{
    float _S23 = alpha_0 * alpha_0;
    float _S24 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S23 * n_dot_h_0 * n_dot_h_0;
    return _S23 / (F32_max((3.14159274101257324f * _S24 * _S24), (1.17549435082228751e-38f)));
}

__device__ float smithG1(float alpha_1, float n_dot_x_0)
{
    float _S25 = alpha_1 * alpha_1;
    float _S26 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S25 + (1.0f - _S25) * n_dot_x_0 * n_dot_x_0))));
    bool _S27 = alpha_1 > 0.0f;
    float _S28 = _slang_select(_S27, _S26,1.0f);
    return _S28;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S29 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S30 = eta_i_0 / eta_o_0 * _S29;
    bool _S31 = _S30 < 1.0f;
    float kr_0;
    if(_S31)
    {
        float _S32 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S30 * _S30))))));
        float _S33 = eta_o_0 * cos_theta_0;
        float _S34 = eta_i_0 * _S32;
        float _S35 = (_S33 - _S34) / (_S33 + _S34);
        float _S36 = eta_i_0 * cos_theta_0;
        float _S37 = eta_o_0 * _S32;
        float _S38 = (_S36 - _S37) / (_S36 + _S37);
        float _S39 = (_S35 * _S35 + _S38 * _S38) / 2.0f;
        kr_0 = _S39;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float unshared_0(float x_13)
{
    return x_13;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_2, float U1_0, float U2_0)
{
    float3  _S40 = make_float3 (alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z);
    float3  _S41 = ((((_S40)) * make_float3(rnorm3df(((_S40)).x, ((_S40)).y, ((_S40)).z))));
    float _S42 = _S41.x;
    float _S43 = _S41.y;
    float _S44 = _S42 * _S42 + _S43 * _S43;
    float3  _S45;
    if(_S44 > 0.0f)
    {
        float3  _S46 = make_float3 (- _S43, _S42, 0.0f);
        float _S47 = (rsqrtf((_S44)));
        _S45 = _S46 * make_float3 (_S47);
    }
    else
    {
        _S45 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S48 = cross_0(_S41, _S45);
    float _S49 = (F32_sqrt((U1_0)));
    float _S50 = 6.28318548202514648f * U2_0;
    float _S51 = _S49 * (F32_cos((_S50)));
    float t2_0 = _S49 * (F32_sin((_S50)));
    float _S52 = 0.5f * (1.0f + _S41.z);
    float t2_1 = (1.0f - _S52) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S51 * _S51)))))) + _S52 * t2_0;
    float3  _S53 = make_float3 (_S51) * _S45 + make_float3 (t2_1) * _S48;
    float _S54 = unshared_0(_S51);
    float _S55 = unshared_0(_S51);
    float3  _S56 = _S53 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S54 * _S55 - t2_1 * t2_1))))))) * _S41;
    float3  _S57 = make_float3 (alpha_2 * _S56.x, alpha_2 * _S56.y, (F32_max((0.0f), (_S56.z))));
    float3  _S58 = ((((_S57)) * make_float3(rnorm3df(((_S57)).x, ((_S57)).y, ((_S57)).z))));
    return _S58;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S59 = (F32_sqrt((random_1_0)));
    float _S60 = 6.28318548202514648f * random_2_0;
    float _S61 = _S59 * (F32_cos((_S60)));
    float _S62 = _S59 * (F32_sin((_S60)));
    float _S63 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S61 * _S61 - _S62 * _S62))))));
    return make_float3 (_S61, _S63, _S62);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S64 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S64)
    {
        float3  _S65 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S65;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S66 = cross_0(n_2, a_1);
    float3  _S67 = ((((_S66)) * make_float3(rnorm3df(((_S66)).x, ((_S66)).y, ((_S66)).z))));
    float3  _S68 = cross_0(n_2, _S67);
    return make_float3 (v_0.x) * _S67 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S68;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S69 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S69)
    {
        float3  _S70 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S70;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S71 = cross_0(n_3, a_3);
    float3  _S72 = ((((_S71)) * make_float3(rnorm3df(((_S71)).x, ((_S71)).y, ((_S71)).z))));
    float3  _S73 = cross_0(n_3, _S72);
    return make_float3 (dot_0(v_1, _S72), dot_0(v_1, n_3), dot_0(v_1, _S73));
}

static __device__ float3  negate_0(float3  x_14)
{
    return - x_14;
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S74 = p1_0 - p0_0;
    float3  _S75 = p2_0 - p0_0;
    float2  _S76 = uv1_0 - uv0_0;
    float2  _S77 = uv2_0 - uv0_0;
    float _S78 = _S76.x;
    float _S79 = _S77.y;
    float _S80 = _S76.y;
    float _S81 = _S77.x;
    float _S82 = _S78 * _S79 - _S80 * _S81;
    float _S83 = 1.0f / _S82;
    float3  t_0 = (_S74 * make_float3 (_S79) - _S75 * make_float3 (_S80)) * make_float3 (_S83);
    float3  _S84 = (_S75 * make_float3 (_S78) - _S74 * make_float3 (_S81)) * make_float3 (_S83);
    float3  _S85 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  t_1 = ((((_S85)) * make_float3(rnorm3df(((_S85)).x, ((_S85)).y, ((_S85)).z))));
    bool _S86 = (dot_0(cross_0(n_4, t_1), _S84)) > 0.0f;
    float3  t_2;
    if(_S86)
    {
        float3  _S87 = negate_0(t_1);
        t_2 = _S87;
    }
    else
    {
        t_2 = t_1;
    }
    float3  _S88 = cross_0(n_4, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S88, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S89 = t1_0 - t0_0;
    float3  _S90 = t2_2 - t0_0;
    float3  _S91 = t2_2 - t1_0;
    float _S92 = (F32_min((length_0(_S89)), ((F32_min((length_0(_S90)), (length_0(_S91)))))));
    float3  _S93 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S94 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S95 = dot_0(geometry_n_0, _S94);
    float3  _S96 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S97 = dot_0(geometry_n_0, _S96);
    float3  _S98 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S99 = acos_0(abs_0(make_float3 (_S95, _S97, dot_0(geometry_n_0, _S98))));
    float3  _S100 = clamp_0(tan_0(_S99), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S93 * _S100, uvw_0), 0.0f, _S92 * 0.125f);
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S101;
    (&_S101)->tangent = tangent_0;
    (&_S101)->alphas = alphas_0;
    return _S101;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S102 = material_0.roughness;
    float _S103 = _S102 * _S102;
    bool _S104 = (material_0.anisotropy) == 0.0f;
    bool _S105;
    if(_S104)
    {
        _S105 = true;
    }
    else
    {
        _S105 = !(_S103 > 0.0f);
    }
    if(_S105)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S106 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S107 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S108 = (dot_0(_S106, _S106)) > 0.0f;
    float3  _S109 = _slang_select(_S108, _S106,_S107);
    float3  _S110 = ((((_S109)) * make_float3(rnorm3df(((_S109)).x, ((_S109)).y, ((_S109)).z))));
    float _S111 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S112 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S113 = 1.0f / _S112;
    bool _S114 = (material_0.anisotropy) < 0.0f;
    float _S115 = _slang_select(_S114, _S113,_S112);
    return AnisotropicFrame_x24init_0(_S110 * make_float3 ((F32_cos((_S111)))) + cross_0(n_i_0, _S110) * make_float3 ((F32_sin((_S111)))), make_float2 (_S103 / _S115, _S103 * _S115));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S116;
    (&_S116)->on = on_0;
    (&_S116)->albedo = albedo_0;
    return _S116;
}

__device__ __forceinline__ SheenProfile sheenProfile(float3  v_3, float3  n_i_1, BSDFMaterial material_1)
{
    SheenProfile _S117 = SheenProfile_x24init_0(false, 0.0f);
    float _S118 = rgb_to_greyscale(material_1.sheen);
    bool _S119 = _S118 > 0.0f;
    SheenProfile profile_0;
    if(_S119)
    {
        float _S120 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S121 = (U32_min((uint(_S120)), (22U)));
        float _S122 = (F32_sqrt((0.05000000074505806f)));
        float _S123 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S122, 1.0f) - _S122) / (1.0f - _S122) * 23.0f;
        uint _S124 = (U32_min((uint(_S123)), (22U)));
        uint _S125 = _S121 * 24U + _S124;
        float _S126 = _S120 - float(_S121);
        float _S127 = _S123 - float(_S124);
        uint _S128 = _S125 + 24U;
        float _S129 = SHEEN_ALBEDO_0[_S125] + (SHEEN_ALBEDO_0[_S128] - SHEEN_ALBEDO_0[_S125]) * _S126;
        uint _S130 = _S125 + 1U;
        float _S131 = SHEEN_ALBEDO_0[_S130] + (SHEEN_ALBEDO_0[_S128 + 1U] - SHEEN_ALBEDO_0[_S130]) * _S126;
        SheenProfile _S132 = SheenProfile_x24init_0(true, (F32_exp((_S129 + (_S131 - _S129) * _S127))));
        profile_0 = _S132;
    }
    else
    {
        profile_0 = _S117;
    }
    return profile_0;
}

__device__ float3  anisotropicLocal(float3  w_0, float3  t_3, float3  n_5)
{
    return make_float3 (dot_0(w_0, t_3), dot_0(w_0, cross_0(n_5, t_3)), dot_0(w_0, n_5));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_4, float3  n_i_2, float alpha_3, AnisotropicFrame frame_0, uint * random_state_0)
{
    Random _S133 = pcg(*random_state_0);
    Random _S134 = pcg(_S133.state);
    *random_state_0 = _S134.state;
    float _S135 = frame_0.alphas.x;
    bool _S136 = _S135 > 0.0f;
    if(_S136)
    {
        float3  _S137 = anisotropicLocal(v_4, frame_0.tangent, n_i_2);
        float _S138 = frame_0.alphas.y;
        float3  _S139 = make_float3 (_S135 * _S137.x, _S138 * _S137.y, _S137.z);
        float3  _S140 = ((((_S139)) * make_float3(rnorm3df(((_S139)).x, ((_S139)).y, ((_S139)).z))));
        float3  _S141 = sampleGGXVNDF(_S140, 1.0f, _S133.value, _S134.value);
        float3  _S142 = make_float3 (_S135 * _S141.x, _S138 * _S141.y, _S141.z);
        float3  _S143 = ((((_S142)) * make_float3(rnorm3df(((_S142)).x, ((_S142)).y, ((_S142)).z))));
        return make_float3 (_S143.x) * frame_0.tangent + make_float3 (_S143.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S143.z) * n_i_2;
    }
    float3  _S144 = worldToTangent(v_4, n_i_2);
    float3  _S145 = sampleGGXVNDF(float3 {_S144.x, _S144.z, _S144.y}, alpha_3, _S133.value, _S134.value);
    float3  _S146 = float3 {_S145.x, _S145.z, _S145.y};
    float3  _S147 = tangentToWorld(_S146, n_i_2);
    return _S147;
}

static __device__ float sign_0(float e_0)
{
    float _S148;
    if(e_0 > 0.0f)
    {
        _S148 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S148 = -1.0f;
        }
        else
        {
            _S148 = 0.0f;
        }
    }
    return _S148;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_6, BSDFMaterial material_2, uint random_state_1, AnisotropicFrame frame_1)
{
    uint state_5 = random_state_1;
    float3  _S149 = negate_0(in_dir_0);
    float _S150 = sign_0(dot_0(n_6, _S149));
    float _S151 = material_2.roughness;
    float3  _S152 = sampleHalfVector(_S149, n_6 * make_float3 (_S150), _S151 * _S151, frame_1, &state_5);
    return _S152;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_7, float eta_i_1, float eta_o_1)
{
    float3  _S153 = negate_0(in_dir_1);
    float3  _S154 = negate_0(make_float3 (eta_i_1) * _S153 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S155 = ((((_S154)) * make_float3(rnorm3df(((_S154)).x, ((_S154)).y, ((_S154)).z))));
    float _S156 = sign_0(dot_0(n_7, _S153));
    float _S157 = sign_0(dot_0(_S154, n_7 * make_float3 (_S156)));
    return _S155 * make_float3 (_S157);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S158 = negate_0(in_dir_2);
    float3  _S159 = _S158 + out_dir_1;
    float3  _S160 = ((((_S159)) * make_float3(rnorm3df(((_S159)).x, ((_S159)).y, ((_S159)).z))));
    return _S160;
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S161 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S161 / (_S161 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S161)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S162 = alphas_2.x;
    float _S163 = h_0.x / _S162;
    float _S164 = alphas_2.y;
    float _S165 = h_0.y / _S164;
    float _S166 = h_0.z;
    float _S167 = _S163 * _S163 + _S165 * _S165 + _S166 * _S166;
    return 1.0f / (F32_max((3.14159274101257324f * _S162 * _S164 * _S167 * _S167), (1.17549435082228751e-38f)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

struct BSDFLobes
{
    float v_dot_h;
    float n_dot_h;
    float3  refracted;
    float3  F;
    float F_greyscale;
    float reflect_weight;
    float3  diffuse_weight;
    float3  refract_weight;
    float p_diffuse;
    float p_reflect;
    float p_refract;
    float translucent_share;
    float3  sheen;
    float p_sheen_velvet;
    float3  view;
    float3  tangent;
    float2  alphas;
    float visible;
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_1, float3  refracted_0, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_1, float2  alphas_3, float visible_0)
{
    BSDFLobes _S168;
    (&_S168)->v_dot_h = v_dot_h_0;
    (&_S168)->n_dot_h = n_dot_h_1;
    (&_S168)->refracted = refracted_0;
    (&_S168)->F = F_0;
    (&_S168)->F_greyscale = F_greyscale_0;
    (&_S168)->reflect_weight = reflect_weight_0;
    (&_S168)->diffuse_weight = diffuse_weight_0;
    (&_S168)->refract_weight = refract_weight_0;
    (&_S168)->p_diffuse = p_diffuse_0;
    (&_S168)->p_reflect = p_reflect_0;
    (&_S168)->p_refract = p_refract_0;
    (&_S168)->translucent_share = translucent_share_0;
    (&_S168)->sheen = sheen_0;
    (&_S168)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S168)->view = view_0;
    (&_S168)->tangent = tangent_1;
    (&_S168)->alphas = alphas_3;
    (&_S168)->visible = visible_0;
    return _S168;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_5, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S169 = dot_0(ggx_n_0, v_5);
    float _S170 = dot_0(n_i_3, ggx_n_0);
    float _S171 = eta_i_2 / eta_o_2;
    float3  _S172 = refract_0(in_dir_3, ggx_n_0, _S171);
    float3  _S173 = ((((_S172)) * make_float3(rnorm3df(((_S172)).x, ((_S172)).y, ((_S172)).z))));
    float _S174 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S175 = _S174 * _S174;
    float _S176 = (1.0f + _S174) / (1.0f - _S174);
    float _S177 = (F32_abs((_S169)));
    bool _S178 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S178)
    {
        sheen_component_0 = _S176;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S178)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S176;
    }
    float _S179 = fresnel(_S177, sheen_component_0, visible_1);
    bool _S180 = (eta_i_2 * eta_i_2 * (1.0f - _S169 * _S169)) >= (eta_o_2 * eta_o_2);
    float3  _S181;
    if(_S180)
    {
        _S181 = make_float3 (1.0f);
    }
    else
    {
        float3  _S182 = material_3.specular_tint * make_float3 (_S175);
        _S181 = _S182 + (make_float3 (1.0f) - _S182) * make_float3 (_S179 - _S175) / make_float3 (1.0f - _S175);
    }
    float3  _S183 = make_float3 (1.0f);
    float3  _S184 = make_float3 (0.0f);
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(sheen_profile_0.on)
    {
        float _S185 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S186 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S185);
        float _S187 = rgb_to_greyscale(material_3.sheen);
        float _S188 = _S187 * _S185;
        float3  _S189 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        scale_0 = _S186;
        sheen_component_0 = _S188;
        sheen_1 = _S189;
        view_1 = v_5;
    }
    else
    {
        scale_0 = _S183;
        sheen_component_0 = 0.0f;
        sheen_1 = _S184;
        view_1 = _S184;
    }
    float3  _S190 = mix_0(_S181, material_3.albedo, material_3.metallic);
    float3  F_1 = _S190 * scale_0;
    float _S191 = rgb_to_greyscale(F_1);
    float _S192 = 1.0f - material_3.metallic;
    float3  _S193 = make_float3 (1.0f) - _S181;
    float3  _S194 = make_float3 ((1.0f - material_3.transmission) * _S192) * _S193 * scale_0;
    float3  _S195 = make_float3 (material_3.transmission * _S192) * _S193 * scale_0;
    float _S196 = (F32_max((_S191), (0.0f)));
    float _S197 = rgb_to_greyscale(_S194);
    float _S198 = (F32_max((_S197), (0.0f)));
    float _S199 = rgb_to_greyscale(_S195);
    float _S200 = sign_0(length_0(_S173));
    float _S201 = (F32_max((_S199 * _S200), (0.0f)));
    float _S202 = _S196 + _S198 + _S201;
    float _S203 = (F32_min((sheen_component_0), (1.0f)));
    bool _S204 = sheen_component_0 > 0.0f;
    bool _S205;
    if(_S204)
    {
        _S205 = !(_S202 > 0.0f);
    }
    else
    {
        _S205 = false;
    }
    float _S206 = _slang_select(_S205, 1.0f,_S203);
    float _S207 = (1.0f - _S206) / (F32_max((_S202), (0.0000152587890625f)));
    float _S208 = _S198 * _S207;
    float _S209 = _S196 * _S207;
    float _S210 = _S201 * _S207;
    bool _S211 = (frame_2.alphas.x) > 0.0f;
    if(_S211)
    {
        float3  _S212 = anisotropicLocal(v_5, frame_2.tangent, n_i_3);
        float _S213 = anisotropicG1(_S212, frame_2.alphas);
        float3  _S214 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S215 = anisotropicD(_S214, frame_2.alphas);
        float _S216 = _S213 * _S215;
        visible_1 = _S216;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S169, _S170, _S173, F_1, _S191, 1.0f, _S194, _S195, _S208, _S209, _S210, 0.0f, sheen_1, _S206, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S217 = rgb_to_greyscale(material_4.translucent);
    float _S218 = rgb_to_greyscale(material_4.albedo);
    float _S219 = _S217 / (_S218 + _S217);
    bool _S220 = _S217 > 0.0f;
    float _S221 = _slang_select(_S220, _S219,0.0f);
    return _S221;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S222 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S223 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S224 = 1.0f - lobes_0.translucent_share;
    bool _S225 = n_i_dot_l_0 < 0.0f;
    float _S226 = _slang_select(_S225, lobes_0.translucent_share,_S224);
    float _S227 = _S223 * _S226;
    bool _S228 = (lobes_0.translucent_share) > 0.0f;
    float _S229 = _slang_select(_S228, _S227,_S222);
    bool _S230 = n_i_dot_v_0 > 0.0f;
    float _S231 = _slang_select(_S230, _S229,0.0f);
    return _S231;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_5, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S232 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S233 = _slang_select(_S232, material_5.translucent,material_5.albedo);
    float _S234 = 1.0f - lobes_1.translucent_share;
    float _S235 = _slang_select(_S232, lobes_1.translucent_share,_S234);
    float3  _S236 = _S233 / make_float3 (_S235);
    bool _S237 = (lobes_1.translucent_share) > 0.0f;
    float3  _S238 = _slang_select(_S237, _S236,material_5.albedo);
    return lobes_1.diffuse_weight * _S238 / make_float3 (lobes_1.p_diffuse);
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S239 = smithG1(alpha_6, n_i_dot_v_1);
    float _S240 = _S239 * lobes_2.v_dot_h;
    float _S241 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S242 = _S240 * _S241 / n_i_dot_v_1;
    bool _S243 = alpha_6 > 0.0f;
    bool _S244;
    if(_S243)
    {
        _S244 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S244 = false;
    }
    if(_S244)
    {
        _S244 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S244 = false;
    }
    if(_S244)
    {
        _S244 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S244 = false;
    }
    float _S245 = _slang_select(_S244, _S242,0.0f);
    bool _S246 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S246)
    {
        float _S247 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S248 = (lobes_2.v_dot_h) > 0.0f;
        if(_S248)
        {
            _S244 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S244 = false;
        }
        if(_S244)
        {
            _S244 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S244 = false;
        }
        float _S249 = _slang_select(_S244, _S247,0.0f);
        pdf_h_0 = _S249;
    }
    else
    {
        pdf_h_0 = _S245;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S250 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S251 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S252 = lobes_3.p_refract * _S250 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S251 * _S251);
    bool _S253 = eta_i_4 != eta_o_4;
    bool _S254;
    if(_S253)
    {
        _S254 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S254 = false;
    }
    float _S255 = _slang_select(_S254, _S252,0.0f);
    return _S255;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S256 = - dot_0(n_i_5, l_1);
    float _S257 = smithG1(alpha_8, (F32_max((_S256), (0.0f))));
    bool _S258 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S258)
    {
        float3  _S259 = negate_0(n_i_5);
        float3  _S260 = anisotropicLocal(l_1, lobes_4.tangent, _S259);
        float _S261 = anisotropicG1(_S260, lobes_4.alphas);
        G1_l_0 = _S261;
    }
    else
    {
        G1_l_0 = _S257;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S262 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S263 = n_i_dot_l_2 > 0.0f;
    bool _S264;
    if(_S263)
    {
        _S264 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S264 = false;
    }
    float _S265 = _slang_select(_S264, _S262,0.0f);
    return _S265;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S266 = l_2 + lobes_6.view;
    float3  _S267 = ((((_S266)) * make_float3(rnorm3df(((_S266)).x, ((_S266)).y, ((_S266)).z))));
    float _S268 = dot_0(n_i_6, _S267);
    float _S269 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S270 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S271 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S272 = (2.0f + _S271) * (F32_pow(((F32_max((1.0f - _S268 * _S268), (0.0f)))), (0.5f * _S271))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S269 + _S270 - _S269 * _S270)), (0.0000152587890625f)));
    return lobes_6.sheen * make_float3 (_S272 * _S269 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S273 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    float _S274 = lobes_7.p_reflect * _S273 / (4.0f * lobes_7.v_dot_h);
    bool _S275 = _S273 > 0.0f;
    float _S276 = _slang_select(_S275, _S274,0.0f);
    return _S276;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S277 = dot_0(n_i_7, l_3);
    float _S278 = smithG1(alpha_12, (F32_max((_S277), (0.0f))));
    bool _S279 = (lobes_8.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S279)
    {
        float3  _S280 = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        float _S281 = anisotropicG1(_S280, lobes_8.alphas);
        G1_l_1 = _S281;
    }
    else
    {
        G1_l_1 = _S278;
    }
    return make_float3 (lobes_8.reflect_weight * G1_l_1) * lobes_8.F / make_float3 (lobes_8.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_8, BSDFMaterial material_9, float eta_i_7, float eta_o_7, bool refracted_1, uint random_state_2, FixedArray<float3 , 4>  * throughputs_0, FixedArray<float, 4>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S282 = negate_0(in_dir_4);
    float _S283 = dot_0(n_8, _S282);
    float _S284 = sign_0(_S283);
    float3  _S285 = n_8 * make_float3 (_S284);
    AnisotropicFrame _S286 = anisotropicFrame(material_9, _S285);
    float _S287 = dot_0(_S285, out_dir_2);
    float _S288 = material_9.roughness;
    float _S289 = _S288 * _S288;
    SheenProfile _S290 = sheenProfile(_S282, _S285, material_9);
    float _S291 = rgb_to_greyscale(material_9.translucent);
    bool _S292 = _S291 > 0.0f;
    bool _S293 = (dot_0(n_8, out_dir_2) * _S283) < 0.0f;
    uint i_10 = 0U;
    for(;;)
    {
        if(i_10 < 4U)
        {
        }
        else
        {
            break;
        }
        float3  _S294 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S294;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S295 = make_float3 (0.0f);
    BSDFLobes _S296 = BSDFLobes_x24init_0(0.0f, 0.0f, _S295, _S295, 0.0f, 0.0f, _S295, _S295, 0.0f, 0.0f, 0.0f, 0.0f, _S295, 0.0f, _S295, _S295, make_float2 (0.0f), 0.0f);
    BSDFLobes lobe_terms_0 = _S296;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S295;
    i_10 = 0U;
    for(;;)
    {
        if(i_10 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S297;
        if(i_10 == 3U)
        {
            _S297 = 4U;
        }
        else
        {
            _S297 = i_10;
        }
        bool _S298 = _S297 == 0U;
        bool _S299;
        if(_S298)
        {
            _S299 = _S292;
        }
        else
        {
            _S299 = false;
        }
        bool _S300;
        if(_S299)
        {
            _S300 = _S293;
        }
        else
        {
            _S300 = _S297 == 1U;
        }
        bool _S301 = _S300 != refracted_1;
        if(_S301)
        {
            ggx_n_1 = ggx_n_2;
            uint i_12 = i_10 + 1U;
            ggx_n_2 = ggx_n_1;
            i_10 = i_12;
            continue;
        }
        uint _S302;
        if(_S297 == 4U)
        {
            _S302 = 2U;
        }
        else
        {
            _S302 = _S297;
        }
        bool _S303 = _S302 != half_of_0;
        uint half_of_1;
        if(_S303)
        {
            bool _S304 = _S302 == 0U;
            if(_S304)
            {
                float3  _S305 = sampledHalf(in_dir_4, n_8, material_9, random_state_2, _S286);
                ggx_n_1 = _S305;
            }
            else
            {
                bool _S306 = _S302 == 1U;
                if(_S306)
                {
                    float3  _S307 = refractedHalf(in_dir_4, out_dir_2, n_8, eta_i_7, eta_o_7);
                    ggx_n_1 = _S307;
                }
                else
                {
                    float3  _S308 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S308;
                }
            }
            float3  _S309 = negate_0(in_dir_4);
            BSDFLobes _S310 = bsdfLobes(in_dir_4, _S309, _S285, ggx_n_1, material_9, eta_i_7, eta_o_7, _S286, _S290);
            lobe_terms_0 = _S310;
            float _S311 = translucentShare(material_9);
            (&lobe_terms_0)->translucent_share = _S311;
            half_of_1 = _S302;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S297)
        {
        case 0U:
            {
                float _S312 = diffusePDF(_S287, 0.0f, (F32_abs((_S283))), _S289, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(0)] = _S312;
                float3  _S313 = diffuseBSDF(out_dir_2, _S285, _S289, material_9, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S313;
                break;
            }
        case 1U:
            {
                float _S314 = refractPDF(_S287, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S283))), _S289, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(1)] = _S314;
                float3  _S315 = refractBSDF(out_dir_2, _S285, _S289, material_9, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S315;
                break;
            }
        case 4U:
            {
                float _S316 = sheenVelvetPDF(_S287, 0.0f, (F32_abs((_S283))), _S289, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(3)] = _S316;
                float3  _S317 = sheenVelvetBSDF(out_dir_2, _S285, _S289, material_9, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S317;
                break;
            }
        default:
            {
                float _S318 = reflectPDF(_S287, 0.0f, (F32_abs((_S283))), _S289, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(2)] = _S318;
                float3  _S319 = reflectBSDF(out_dir_2, _S285, _S289, material_9, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S319;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_12 = i_10 + 1U;
        ggx_n_2 = ggx_n_1;
        i_10 = i_12;
    }
    i_10 = 0U;
    ggx_n_1 = _S295;
    for(;;)
    {
        if(i_10 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S320 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S320)
        {
            float3  f_0 = ggx_n_1 + (*throughputs_0)[i_10] * make_float3 ((*pdfs_0)[i_10]);
            ggx_n_1 = f_0;
        }
        uint i_13 = i_10 + 1U;
        i_10 = i_13;
    }
    return ggx_n_1;
}

struct SampleBSDF
{
    float3  unit_direction;
    float3  throughput;
    uint random_state;
    bool refracted;
    uint lobe;
    float pdf;
};

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_0, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_0, float pdf_0)
{
    SampleBSDF _S321;
    (&_S321)->unit_direction = unit_direction_0;
    (&_S321)->throughput = throughput_0;
    (&_S321)->random_state = random_state_3;
    (&_S321)->refracted = refracted_2;
    (&_S321)->lobe = lobe_0;
    (&_S321)->pdf = pdf_0;
    return _S321;
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_0, float3  n_i_8, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_10, BSDFLobes lobes_9, float eta_i_8, float eta_o_8, uint random_state_4)
{
    float3  _S322 = make_float3 (1.0f);
    SampleBSDF _S323 = SampleBSDF_x24init_0(_S322, _S322, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S323;
    Random _S324 = pcg(random_state_4);
    Random _S325 = pcg(_S324.state);
    (&sample_0)->random_state = _S325.state;
    float3  _S326 = sampleCosWeightedHemisphere(_S324.value, _S325.value);
    bool _S327 = u_0 < (lobes_9.p_diffuse * lobes_9.translucent_share);
    float _S328 = _S326.y;
    float _S329 = - _S328;
    float _S330 = _slang_select(_S327, _S329,_S328);
    float3  _S331 = tangentToWorld(make_float3 (_S326.x, _S330, _S326.z), n_i_8);
    (&sample_0)->unit_direction = _S331;
    (&sample_0)->refracted = _S327;
    (&sample_0)->lobe = 0U;
    float3  _S332 = diffuseBSDF((&sample_0)->unit_direction, n_i_8, alpha_13, material_10, lobes_9);
    (&sample_0)->throughput = _S332;
    float _S333 = diffusePDF(_S330, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_8, eta_o_8);
    (&sample_0)->pdf = _S333;
    return sample_0;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_11, BSDFLobes lobes_10, float eta_i_9, float eta_o_9, uint random_state_5)
{
    float3  _S334 = make_float3 (1.0f);
    SampleBSDF _S335 = SampleBSDF_x24init_0(_S334, _S334, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S335;
    Random _S336 = pcg(random_state_5);
    Random _S337 = pcg(_S336.state);
    (&sample_1)->random_state = _S337.state;
    float _S338 = _S336.value;
    float _S339 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S338 * _S338))))));
    float _S340 = 6.28318548202514648f * _S337.value;
    float3  _S341 = tangentToWorld(make_float3 (_S339 * (F32_cos((_S340))), _S336.value, _S339 * (F32_sin((_S340)))), n_i_9);
    (&sample_1)->unit_direction = _S341;
    (&sample_1)->lobe = 4U;
    float3  _S342 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_14, material_11, lobes_10);
    (&sample_1)->throughput = _S342;
    float _S343 = sheenVelvetPDF(_S336.value, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_9, eta_o_9);
    (&sample_1)->pdf = _S343;
    return sample_1;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_10, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_12, BSDFLobes lobes_11, float eta_i_10, float eta_o_10, uint random_state_6)
{
    float3  _S344 = make_float3 (1.0f);
    SampleBSDF _S345 = SampleBSDF_x24init_0(_S344, _S344, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S345;
    (&sample_2)->unit_direction = lobes_11.refracted;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->refracted = true;
    (&sample_2)->lobe = 1U;
    float3  _S346 = refractBSDF((&sample_2)->unit_direction, n_i_10, alpha_15, material_12, lobes_11);
    (&sample_2)->throughput = _S346;
    float _S347 = refractPDF(0.0f, dot_0((&sample_2)->unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_10, eta_o_10);
    (&sample_2)->pdf = _S347;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_11, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_13, BSDFLobes lobes_12, float eta_i_11, float eta_o_11, uint random_state_7)
{
    float3  _S348 = make_float3 (1.0f);
    SampleBSDF _S349 = SampleBSDF_x24init_0(_S348, _S348, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S349;
    float3  _S350 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S351 = ((((_S350)) * make_float3(rnorm3df(((_S350)).x, ((_S350)).y, ((_S350)).z))));
    (&sample_3)->unit_direction = _S351;
    (&sample_3)->random_state = random_state_7;
    (&sample_3)->lobe = 2U;
    float3  _S352 = reflectBSDF((&sample_3)->unit_direction, n_i_11, alpha_16, material_13, lobes_12);
    (&sample_3)->throughput = _S352;
    float _S353 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_11, eta_o_11);
    (&sample_3)->pdf = _S353;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_9, BSDFMaterial material_14, float eta_i_12, float eta_o_12, uint random_init_0, float2  screen_space_0)
{
    uint random_state_8 = random_init_0;
    float3  _S354 = negate_0(in_dir_6);
    float _S355 = dot_0(n_9, _S354);
    float _S356 = sign_0(_S355);
    float3  n_i_12 = n_9 * make_float3 (_S356);
    float _S357 = (F32_abs((_S355)));
    float _S358 = material_14.roughness;
    float _S359 = _S358 * _S358;
    AnisotropicFrame _S360 = anisotropicFrame(material_14, n_i_12);
    SheenProfile _S361 = sheenProfile(_S354, n_i_12, material_14);
    float3  _S362 = sampleHalfVector(_S354, n_i_12, _S359, _S360, &random_state_8);
    BSDFLobes _S363 = bsdfLobes(in_dir_6, _S354, n_i_12, _S362, material_14, eta_i_12, eta_o_12, _S360, _S361);
    BSDFLobes lobes_13 = _S363;
    float _S364 = translucentShare(material_14);
    (&lobes_13)->translucent_share = _S364;
    Random _S365 = pcg(random_state_8);
    random_state_8 = _S365.state;
    bool _S366 = (_S365.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S366)
    {
        SampleBSDF _S367 = sheenVelvetSample(n_i_12, _S357, _S359, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S367;
    }
    float _S368 = _S365.value - (&lobes_13)->p_sheen_velvet;
    bool _S369 = _S368 < ((&lobes_13)->p_diffuse);
    if(_S369)
    {
        SampleBSDF _S370 = diffuseSample(_S368, n_i_12, _S357, _S359, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S370;
    }
    bool _S371 = _S368 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S371)
    {
        SampleBSDF _S372 = refractSample(_S362, n_i_12, _S357, _S359, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S372;
    }
    SampleBSDF _S373 = reflectSample(in_dir_6, _S362, n_i_12, _S357, _S359, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
    return _S373;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S374 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S374));
}

__device__ float2  vertexEta(BSDFMaterial material_15, float n_dot_v_0)
{
    bool _S375 = n_dot_v_0 < 0.0f;
    float _S376 = _slang_select(_S375, material_15.ior,1.0f);
    float _S377 = _slang_select(_S375, 1.0f,material_15.ior);
    return make_float2 (_S376, _S377);
}

__device__ bool neeDecision(BSDFMaterial material_16, float n_dot_v_1, float eta_i_13, float eta_o_13)
{
    float _S378 = fresnel((F32_abs((n_dot_v_1))), eta_i_13, eta_o_13);
    float3  _S379 = mix_0(make_float3 (_S378), material_16.albedo, material_16.metallic);
    float _S380 = rgb_to_greyscale(_S379);
    float _S381 = (F32_max(((1.0f - _S380) * (1.0f - material_16.metallic) * (1.0f - material_16.transmission)), (0.0f)));
    bool _S382 = _S381 > 0.03999999910593033f;
    bool _S383;
    if(_S382)
    {
        _S383 = true;
    }
    else
    {
        _S383 = (material_16.roughness) > 0.20000000298023224f;
    }
    return _S383;
}

__device__ float3  straightThrough(float3  dir_0, float3  n_10, BSDFMaterial material_17)
{
    float3  _S384 = negate_0(dir_0);
    float _S385 = sign_0(dot_0(n_10, _S384));
    float3  _S386 = n_10 * make_float3 (_S385);
    AnisotropicFrame _S387 = anisotropicFrame(material_17, _S386);
    bool _S388 = (_S387.alphas.x) > 0.0f;
    if(_S388)
    {
        float _S389 = material_17.transmission * (1.0f - material_17.metallic);
        float3  _S390 = negate_0(_S386);
        float3  _S391 = anisotropicLocal(dir_0, _S387.tangent, _S390);
        float _S392 = anisotropicG1(_S391, _S387.alphas);
        return make_float3 (_S389 * _S392) * material_17.albedo;
    }
    float _S393 = material_17.transmission * (1.0f - material_17.metallic);
    float _S394 = material_17.roughness;
    float _S395 = smithG1(_S394 * _S394, (F32_abs((dot_0(n_10, dir_0)))));
    return make_float3 (_S393 * _S395) * material_17.albedo;
}

__device__ float hairRow(float3  in_dir_7, float3  t_4, float3  out_dir_3, uint p_0, float w_2, float alpha_17, uint nt_0)
{
    uint _S396 = p_0 % 4U;
    float _S397 = w_2 * HAIR_WIDTHS_0[_S396];
    float _S398 = (F32_asin((clamp_1(dot_0(out_dir_3, t_4), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_7, t_4), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S396] * alpha_17;
    return ((F32_asinh((_S398 / _S397))) / (F32_asinh((3.14159274101257324f / _S397))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_8, float3  t_5, float3  out_dir_4, uint np_0)
{
    float3  _S399 = worldToTangent(out_dir_4, t_5);
    float3  _S400 = worldToTangent(in_dir_8, t_5);
    return (F32_frac((((F32_atan2((_S399.z), (_S399.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S400.z), (1.17549435082228751e-38f - _S400.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_9, float3  t_6, uint p_1, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S401 = worldToTangent(in_dir_9, t_6);
    uint _S402 = p_1 % 4U;
    float _S403 = w_3 * HAIR_WIDTHS_0[_S402];
    float _S404 = (F32_asin((clamp_1(dot_0(in_dir_9, t_6), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S402] * alpha_18 + _S403 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S403))))));
    float _S405 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S401.z), (1.17549435082228751e-38f - _S401.x)));
    float _S406 = (F32_cos((_S404)));
    float3  _S407 = tangentToWorld(make_float3 (_S406 * (F32_cos((_S405))), (F32_sin((_S404))), _S406 * (F32_sin((_S405)))), t_6);
    return _S407;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S408 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S408 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_11, BSDFMaterial material_18, float coverage_0)
{
    float3  _S409;
    if((material_18.ior) == 1.0f)
    {
        float3  _S410 = straightThrough(toward_0, n_11, material_18);
        _S409 = _S410;
    }
    else
    {
        _S409 = make_float3 (0.0f);
    }
    return _S409 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S411 = hash(index_0);
    uint _S412 = hash(seed_0 ^ _S411);
    return _S412;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S413 = a_4 / b_0;
    float3  _S414 = make_float3 (0.0f);
    bool3  _S415 = b_0 == _S414;
    float3  _S416 = _slang_select(_S415, _S414,_S413);
    return _S416;
}

struct Selection
{
    Reservoir r;
    float w_sum;
    float3  color;
    uint random_state;
};

__device__ void offer(Selection * sel_0, Reservoir candidate_0, float3  weight_0)
{
    float _S417 = rgb_to_greyscale(weight_0);
    bool _S418 = _S417 > 0.0f;
    bool _S419;
    if(_S418)
    {
        _S419 = _S417 < 3.00000000549775576e+38f;
    }
    else
    {
        _S419 = false;
    }
    bool _S420 = !_S419;
    if(_S420)
    {
        return;
    }
    float _S421 = sel_0->w_sum + _S417;
    sel_0->w_sum = _S421;
    float3  _S422 = sel_0->color + weight_0;
    sel_0->color = _S422;
    Random _S423 = pcg(sel_0->random_state);
    sel_0->random_state = _S423.state;
    bool _S424 = (_S423.value * sel_0->w_sum) <= _S417;
    if(_S424)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S425 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S425;
    float _S426 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S426;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S427 = rgb_to_greyscale((&r_1)->f);
    float _S428 = sel_2.w_sum / _S427;
    bool _S429 = _S427 > 0.0f;
    float _S430 = _slang_select(_S429, _S428,0.0f);
    (&r_1)->w = _S430;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S431 = (1U << count_0) - 1U;
    return (e_1 & (~(_S431 << offset_0))) | ((newbits_0 & _S431) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S432 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S433 = insertBits_0(_S432, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S433;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S434 = transmission_0 > 0.0f;
    bool _S435;
    if(_S434)
    {
        _S435 = true;
    }
    else
    {
        _S435 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S436;
    if(_S435)
    {
        _S436 = 1.0f;
    }
    else
    {
        _S436 = -1.0f;
    }
    return _S436;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S437 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S438 = cos_a_0 > cos_b_0;
    float _S439 = _slang_select(_S438, 1.0f,_S437);
    return _S439;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_2, float3  normal_0)
{
    float3  _S440 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S441 = node_0.high - node_0.low;
    float3  _S442 = p_2 - _S440;
    float3  _S443 = ((((_S442)) * make_float3(rnorm3df(((_S442)).x, ((_S442)).y, ((_S442)).z))));
    float _S444 = dot_0(_S442, _S442);
    float _S445 = dot_0(_S441, _S441) / 4.0f;
    float _S446 = (F32_abs((dot_0(node_0.w, _S443))));
    float _S447 = sine(node_0.cos_theta_o);
    float _S448 = (F32_sqrt(((F32_max((1.0f - _S445 / _S444), (0.0f))))));
    bool _S449 = _S444 < _S445;
    float _S450 = _slang_select(_S449, -1.0f,_S448);
    float _S451 = sine(_S450);
    float _S452 = sine(_S446);
    float _S453 = cosSubClamped(_S452, _S446, _S447, node_0.cos_theta_o);
    float _S454 = sine(_S446);
    float _S455 = _S454 * node_0.cos_theta_o - _S446 * _S447;
    bool _S456 = _S446 > (node_0.cos_theta_o);
    float _S457 = _slang_select(_S456, 0.0f,_S455);
    float _S458 = cosSubClamped(_S457, _S453, _S451, _S450);
    bool _S459 = _S458 <= 0.0f;
    if(_S459)
    {
        return 0.0f;
    }
    float _S460 = - dot_0(_S443, normal_0);
    float _S461 = node_0.phi * _S458 / (F32_max((_S444), (length_0(_S441) / 2.0f)));
    float _S462 = sine(_S460);
    float _S463 = cosSubClamped(_S462, _S460, _S451, _S450);
    bool _S464 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S465 = _slang_select(_S464, 1.0f,_S463);
    return (F32_max((_S461 * _S465), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_3, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S466 = importance(first_0, p_3, normal_2);
    float _S467 = importance(second_0, p_3, normal_2);
    float2  _S468 = make_float2 (_S466, _S467);
    bool _S469 = _S466 == 0.0f;
    bool _S470;
    if(_S469)
    {
        _S470 = _S467 == 0.0f;
    }
    else
    {
        _S470 = false;
    }
    if(_S470)
    {
        return 2U;
    }
    float _S471 = _S466 + _S467;
    bool _S472 = _S467 > 0.0f;
    if(_S472)
    {
        _S470 = (*pick_0 * _S471) >= _S466;
    }
    else
    {
        _S470 = false;
    }
    uint _S473 = uint(_S470);
    float _S474 = (F32_min(((*pick_0 * _S471 - float(_S473) * _S466) / _slang_vector_get_element(_S468, _S473)), (0.99999994039535522f)));
    *pick_0 = _S474;
    float _S475 = *probability_1 * (_slang_vector_get_element(_S468, _S473) / _S471);
    *probability_1 = _S475;
    return _S473;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_4, float3  normal_3, uint child_0)
{
    float _S476 = importance(first_1, p_4, normal_3);
    float _S477 = importance(second_1, p_4, normal_3);
    float2  _S478 = make_float2 (_S476, _S477);
    float _S479 = _slang_vector_get_element(_S478, child_0) / (_S476 + _S477);
    bool _S480 = _slang_vector_get_element(_S478, child_0) > 0.0f;
    float _S481 = _slang_select(_S480, _S479,0.0f);
    return _S481;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S482 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S483 = b_1 > 0.0f;
    float _S484 = _slang_select(_S483, _S482,1.0f);
    return _S484;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_5)
{
    float3  _S485 = center_0 - p_5;
    float _S486 = radius_1 * radius_1 / dot_0(_S485, _S485);
    bool _S487 = _S486 >= 1.0f;
    if(_S487)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S486)))) / (6.28318548202514648f * _S486);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_6, float u1_0, float u2_0)
{
    float3  _S488 = center_1 - p_6;
    float _S489 = radius_2 * radius_2 / dot_0(_S488, _S488);
    float _S490 = u1_0 * _S489 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S489), (0.0f)))))));
    float _S491 = 2.0f * u1_0;
    bool _S492 = _S489 >= 1.0f;
    float _S493 = _slang_select(_S492, _S491,_S490);
    float _S494 = (F32_sqrt(((F32_max((_S493 * (2.0f - _S493)), (0.0f))))));
    float _S495 = 6.28318548202514648f * u2_0;
    float3  _S496 = make_float3 (_S494 * (F32_cos((_S495))), 1.0f - _S493, _S494 * (F32_sin((_S495))));
    float3  _S497 = ((((_S488)) * make_float3(rnorm3df(((_S488)).x, ((_S488)).y, ((_S488)).z))));
    float3  _S498 = tangentToWorld(_S496, _S497);
    return _S498;
}

#undef Matrix
