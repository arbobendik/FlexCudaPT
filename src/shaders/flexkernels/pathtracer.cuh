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
        bool _S33 = eta_i_0 == eta_o_0;
        float _S34 = _slang_select(_S33, cos_theta_0,_S32);
        float _S35 = eta_o_0 * cos_theta_0;
        float _S36 = eta_i_0 * _S34;
        float _S37 = (_S35 - _S36) / (_S35 + _S36);
        float _S38 = eta_i_0 * cos_theta_0;
        float _S39 = eta_o_0 * _S34;
        float _S40 = (_S38 - _S39) / (_S38 + _S39);
        float _S41 = (_S37 * _S37 + _S40 * _S40) / 2.0f;
        kr_0 = _S41;
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
    float3  _S42 = make_float3 (alpha_2 * Ve_0.x, alpha_2 * Ve_0.y, Ve_0.z);
    float3  _S43 = ((((_S42)) * make_float3(rnorm3df(((_S42)).x, ((_S42)).y, ((_S42)).z))));
    float _S44 = _S43.x;
    float _S45 = _S43.y;
    float _S46 = _S44 * _S44 + _S45 * _S45;
    float3  _S47;
    if(_S46 > 0.0f)
    {
        float3  _S48 = make_float3 (- _S45, _S44, 0.0f);
        float _S49 = (rsqrtf((_S46)));
        _S47 = _S48 * make_float3 (_S49);
    }
    else
    {
        _S47 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S50 = cross_0(_S43, _S47);
    float _S51 = (F32_sqrt((U1_0)));
    float _S52 = 6.28318548202514648f * U2_0;
    float _S53 = _S51 * (F32_cos((_S52)));
    float t2_0 = _S51 * (F32_sin((_S52)));
    float _S54 = 0.5f * (1.0f + _S43.z);
    float t2_1 = (1.0f - _S54) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S53 * _S53)))))) + _S54 * t2_0;
    float3  _S55 = make_float3 (_S53) * _S47 + make_float3 (t2_1) * _S50;
    float _S56 = unshared_0(_S53);
    float _S57 = unshared_0(_S53);
    float3  _S58 = _S55 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S56 * _S57 - t2_1 * t2_1))))))) * _S43;
    float3  _S59 = make_float3 (alpha_2 * _S58.x, alpha_2 * _S58.y, (F32_max((0.0f), (_S58.z))));
    float3  _S60 = ((((_S59)) * make_float3(rnorm3df(((_S59)).x, ((_S59)).y, ((_S59)).z))));
    return _S60;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S61 = (F32_sqrt((random_1_0)));
    float _S62 = 6.28318548202514648f * random_2_0;
    float _S63 = _S61 * (F32_cos((_S62)));
    float _S64 = _S61 * (F32_sin((_S62)));
    float _S65 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S63 * _S63 - _S64 * _S64))))));
    return make_float3 (_S63, _S65, _S64);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S66 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S66)
    {
        float3  _S67 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S67;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S68 = cross_0(n_2, a_1);
    float3  _S69 = ((((_S68)) * make_float3(rnorm3df(((_S68)).x, ((_S68)).y, ((_S68)).z))));
    float3  _S70 = cross_0(n_2, _S69);
    return make_float3 (v_0.x) * _S69 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S70;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S71 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S71)
    {
        float3  _S72 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S72;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S73 = cross_0(n_3, a_3);
    float3  _S74 = ((((_S73)) * make_float3(rnorm3df(((_S73)).x, ((_S73)).y, ((_S73)).z))));
    float3  _S75 = cross_0(n_3, _S74);
    return make_float3 (dot_0(v_1, _S74), dot_0(v_1, n_3), dot_0(v_1, _S75));
}

static __device__ float3  negate_0(float3  x_14)
{
    return - x_14;
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S76 = p1_0 - p0_0;
    float3  _S77 = p2_0 - p0_0;
    float2  _S78 = uv1_0 - uv0_0;
    float2  _S79 = uv2_0 - uv0_0;
    float _S80 = _S78.x;
    float _S81 = _S79.y;
    float _S82 = _S78.y;
    float _S83 = _S79.x;
    float _S84 = _S80 * _S81 - _S82 * _S83;
    float _S85 = 1.0f / _S84;
    float3  t_0 = (_S76 * make_float3 (_S81) - _S77 * make_float3 (_S82)) * make_float3 (_S85);
    float3  _S86 = (_S77 * make_float3 (_S80) - _S76 * make_float3 (_S83)) * make_float3 (_S85);
    float3  _S87 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  _S88 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_4);
    bool _S89 = (dot_0(_S87, _S87)) > 0.0f;
    float3  _S90 = _slang_select(_S89, _S87,_S88);
    float3  _S91 = ((((_S90)) * make_float3(rnorm3df(((_S90)).x, ((_S90)).y, ((_S90)).z))));
    bool _S92 = (dot_0(cross_0(n_4, _S91), _S86)) > 0.0f;
    float3  t_1;
    if(_S92)
    {
        float3  _S93 = negate_0(_S91);
        t_1 = _S93;
    }
    else
    {
        t_1 = _S91;
    }
    float3  _S94 = cross_0(n_4, t_1);
    return makeMatrix<float, 3, 3> (t_1, _S94, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S95 = t1_0 - t0_0;
    float3  _S96 = t2_2 - t0_0;
    float3  _S97 = t2_2 - t1_0;
    float _S98 = (F32_min((length_0(_S95)), ((F32_min((length_0(_S96)), (length_0(_S97)))))));
    float3  _S99 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S100 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S101 = dot_0(geometry_n_0, _S100);
    float3  _S102 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S103 = dot_0(geometry_n_0, _S102);
    float3  _S104 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S105 = acos_0(abs_0(make_float3 (_S101, _S103, dot_0(geometry_n_0, _S104))));
    float3  _S106 = clamp_0(tan_0(_S105), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S99 * _S106, uvw_0), 0.0f, _S98 * 0.125f);
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S107;
    (&_S107)->tangent = tangent_0;
    (&_S107)->alphas = alphas_0;
    return _S107;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S108 = material_0.roughness;
    float _S109 = _S108 * _S108;
    bool _S110 = (material_0.anisotropy) == 0.0f;
    bool _S111;
    if(_S110)
    {
        _S111 = true;
    }
    else
    {
        _S111 = !(_S109 > 0.0f);
    }
    if(_S111)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S112 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S113 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S114 = (dot_0(_S112, _S112)) > 0.0f;
    float3  _S115 = _slang_select(_S114, _S112,_S113);
    float3  _S116 = ((((_S115)) * make_float3(rnorm3df(((_S115)).x, ((_S115)).y, ((_S115)).z))));
    float _S117 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S118 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S119 = 1.0f / _S118;
    bool _S120 = (material_0.anisotropy) < 0.0f;
    float _S121 = _slang_select(_S120, _S119,_S118);
    return AnisotropicFrame_x24init_0(_S116 * make_float3 ((F32_cos((_S117)))) + cross_0(n_i_0, _S116) * make_float3 ((F32_sin((_S117)))), make_float2 (_S109 / _S121, _S109 * _S121));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S122;
    (&_S122)->on = on_0;
    (&_S122)->albedo = albedo_0;
    return _S122;
}

__device__ __forceinline__ SheenProfile sheenProfile(float3  v_3, float3  n_i_1, BSDFMaterial material_1)
{
    SheenProfile _S123 = SheenProfile_x24init_0(false, 0.0f);
    float _S124 = rgb_to_greyscale(material_1.sheen);
    bool _S125 = _S124 > 0.0f;
    SheenProfile profile_0;
    if(_S125)
    {
        float _S126 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S127 = (U32_min((uint(_S126)), (22U)));
        float _S128 = (F32_sqrt((0.05000000074505806f)));
        float _S129 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S128, 1.0f) - _S128) / (1.0f - _S128) * 23.0f;
        uint _S130 = (U32_min((uint(_S129)), (22U)));
        uint _S131 = _S127 * 24U + _S130;
        float _S132 = _S126 - float(_S127);
        float _S133 = _S129 - float(_S130);
        uint _S134 = _S131 + 24U;
        float _S135 = SHEEN_ALBEDO_0[_S131] + (SHEEN_ALBEDO_0[_S134] - SHEEN_ALBEDO_0[_S131]) * _S132;
        uint _S136 = _S131 + 1U;
        float _S137 = SHEEN_ALBEDO_0[_S136] + (SHEEN_ALBEDO_0[_S134 + 1U] - SHEEN_ALBEDO_0[_S136]) * _S132;
        SheenProfile _S138 = SheenProfile_x24init_0(true, (F32_exp((_S135 + (_S137 - _S135) * _S133))));
        profile_0 = _S138;
    }
    else
    {
        profile_0 = _S123;
    }
    return profile_0;
}

__device__ float3  anisotropicLocal(float3  w_0, float3  t_2, float3  n_5)
{
    return make_float3 (dot_0(w_0, t_2), dot_0(w_0, cross_0(n_5, t_2)), dot_0(w_0, n_5));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_4, float3  n_i_2, float alpha_3, AnisotropicFrame frame_0, uint * random_state_0)
{
    Random _S139 = pcg(*random_state_0);
    Random _S140 = pcg(_S139.state);
    *random_state_0 = _S140.state;
    float _S141 = frame_0.alphas.x;
    bool _S142 = _S141 > 0.0f;
    if(_S142)
    {
        float3  _S143 = anisotropicLocal(v_4, frame_0.tangent, n_i_2);
        float _S144 = frame_0.alphas.y;
        float3  _S145 = make_float3 (_S141 * _S143.x, _S144 * _S143.y, _S143.z);
        float3  _S146 = ((((_S145)) * make_float3(rnorm3df(((_S145)).x, ((_S145)).y, ((_S145)).z))));
        float3  _S147 = sampleGGXVNDF(_S146, 1.0f, _S139.value, _S140.value);
        float3  _S148 = make_float3 (_S141 * _S147.x, _S144 * _S147.y, _S147.z);
        float3  _S149 = ((((_S148)) * make_float3(rnorm3df(((_S148)).x, ((_S148)).y, ((_S148)).z))));
        return make_float3 (_S149.x) * frame_0.tangent + make_float3 (_S149.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S149.z) * n_i_2;
    }
    float3  _S150 = worldToTangent(v_4, n_i_2);
    float3  _S151 = sampleGGXVNDF(float3 {_S150.x, _S150.z, _S150.y}, alpha_3, _S139.value, _S140.value);
    float3  _S152 = float3 {_S151.x, _S151.z, _S151.y};
    float3  _S153 = tangentToWorld(_S152, n_i_2);
    return _S153;
}

static __device__ float sign_0(float e_0)
{
    float _S154;
    if(e_0 > 0.0f)
    {
        _S154 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S154 = -1.0f;
        }
        else
        {
            _S154 = 0.0f;
        }
    }
    return _S154;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_6, BSDFMaterial material_2, uint random_state_1, AnisotropicFrame frame_1)
{
    uint state_5 = random_state_1;
    float3  _S155 = negate_0(in_dir_0);
    float _S156 = sign_0(dot_0(n_6, _S155));
    float _S157 = material_2.roughness;
    float3  _S158 = sampleHalfVector(_S155, n_6 * make_float3 (_S156), _S157 * _S157, frame_1, &state_5);
    return _S158;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_7, float eta_i_1, float eta_o_1)
{
    float3  _S159 = negate_0(in_dir_1);
    float3  _S160 = negate_0(make_float3 (eta_i_1) * _S159 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S161 = ((((_S160)) * make_float3(rnorm3df(((_S160)).x, ((_S160)).y, ((_S160)).z))));
    float _S162 = sign_0(dot_0(n_7, _S159));
    float _S163 = sign_0(dot_0(_S160, n_7 * make_float3 (_S162)));
    return _S161 * make_float3 (_S163);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S164 = negate_0(in_dir_2);
    float3  _S165 = _S164 + out_dir_1;
    float3  _S166 = ((((_S165)) * make_float3(rnorm3df(((_S165)).x, ((_S165)).y, ((_S165)).z))));
    return _S166;
}

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S167 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S167 / (_S167 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S167)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S168 = alphas_2.x;
    float _S169 = h_0.x / _S168;
    float _S170 = alphas_2.y;
    float _S171 = h_0.y / _S170;
    float _S172 = h_0.z;
    float _S173 = _S169 * _S169 + _S171 * _S171 + _S172 * _S172;
    return 1.0f / (F32_max((3.14159274101257324f * _S168 * _S170 * _S173 * _S173), (1.17549435082228751e-38f)));
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
    BSDFLobes _S174;
    (&_S174)->v_dot_h = v_dot_h_0;
    (&_S174)->n_dot_h = n_dot_h_1;
    (&_S174)->refracted = refracted_0;
    (&_S174)->F = F_0;
    (&_S174)->F_greyscale = F_greyscale_0;
    (&_S174)->reflect_weight = reflect_weight_0;
    (&_S174)->diffuse_weight = diffuse_weight_0;
    (&_S174)->refract_weight = refract_weight_0;
    (&_S174)->p_diffuse = p_diffuse_0;
    (&_S174)->p_reflect = p_reflect_0;
    (&_S174)->p_refract = p_refract_0;
    (&_S174)->translucent_share = translucent_share_0;
    (&_S174)->sheen = sheen_0;
    (&_S174)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S174)->view = view_0;
    (&_S174)->tangent = tangent_1;
    (&_S174)->alphas = alphas_3;
    (&_S174)->visible = visible_0;
    return _S174;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_5, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S175 = dot_0(ggx_n_0, v_5);
    float _S176 = dot_0(n_i_3, ggx_n_0);
    float _S177 = eta_i_2 / eta_o_2;
    float3  _S178 = refract_0(in_dir_3, ggx_n_0, _S177);
    float3  _S179 = ((((_S178)) * make_float3(rnorm3df(((_S178)).x, ((_S178)).y, ((_S178)).z))));
    float _S180 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S181 = _S180 * _S180;
    float _S182 = (1.0f + _S180) / (1.0f - _S180);
    float _S183 = (F32_abs((_S175)));
    bool _S184 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S184)
    {
        sheen_component_0 = _S182;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float visible_1;
    if(_S184)
    {
        visible_1 = 1.0f;
    }
    else
    {
        visible_1 = _S182;
    }
    float _S185 = fresnel(_S183, sheen_component_0, visible_1);
    bool _S186 = (eta_i_2 * eta_i_2 * (1.0f - _S175 * _S175)) >= (eta_o_2 * eta_o_2);
    float3  _S187;
    if(_S186)
    {
        _S187 = make_float3 (1.0f);
    }
    else
    {
        float3  _S188 = material_3.specular_tint * make_float3 (_S181);
        _S187 = _S188 + (make_float3 (1.0f) - _S188) * make_float3 (_S185 - _S181) / make_float3 (1.0f - _S181);
    }
    float3  _S189 = make_float3 (1.0f);
    float3  _S190 = make_float3 (0.0f);
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    if(sheen_profile_0.on)
    {
        float _S191 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S192 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S191);
        float _S193 = rgb_to_greyscale(material_3.sheen);
        float _S194 = _S193 * _S191;
        float3  _S195 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        scale_0 = _S192;
        sheen_component_0 = _S194;
        sheen_1 = _S195;
        view_1 = v_5;
    }
    else
    {
        scale_0 = _S189;
        sheen_component_0 = 0.0f;
        sheen_1 = _S190;
        view_1 = _S190;
    }
    float3  _S196 = mix_0(_S187, material_3.albedo, material_3.metallic);
    float3  F_1 = _S196 * scale_0;
    float _S197 = rgb_to_greyscale(F_1);
    float _S198 = 1.0f - material_3.metallic;
    float3  _S199 = make_float3 (1.0f) - _S187;
    float3  _S200 = make_float3 ((1.0f - material_3.transmission) * _S198) * _S199 * scale_0;
    float3  _S201 = make_float3 (material_3.transmission * _S198) * _S199 * scale_0;
    float _S202 = (F32_max((_S197), (0.0f)));
    float _S203 = rgb_to_greyscale(_S200);
    float _S204 = (F32_max((_S203), (0.0f)));
    float _S205 = rgb_to_greyscale(_S201);
    float _S206 = sign_0(length_0(_S179));
    float _S207 = (F32_max((_S205 * _S206), (0.0f)));
    float _S208 = _S202 + _S204 + _S207;
    float _S209 = (F32_min((sheen_component_0), (1.0f)));
    bool _S210 = sheen_component_0 > 0.0f;
    bool _S211;
    if(_S210)
    {
        _S211 = !(_S208 > 0.0f);
    }
    else
    {
        _S211 = false;
    }
    float _S212 = _slang_select(_S211, 1.0f,_S209);
    float _S213 = (1.0f - _S212) / (F32_max((_S208), (0.0000152587890625f)));
    float _S214 = _S204 * _S213;
    float _S215 = _S202 * _S213;
    float _S216 = _S207 * _S213;
    bool _S217 = (frame_2.alphas.x) > 0.0f;
    if(_S217)
    {
        float3  _S218 = anisotropicLocal(v_5, frame_2.tangent, n_i_3);
        float _S219 = anisotropicG1(_S218, frame_2.alphas);
        float3  _S220 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S221 = anisotropicD(_S220, frame_2.alphas);
        float _S222 = _S219 * _S221;
        visible_1 = _S222;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S175, _S176, _S179, F_1, _S197, 1.0f, _S200, _S201, _S214, _S215, _S216, 0.0f, sheen_1, _S212, view_1, frame_2.tangent, frame_2.alphas, visible_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S223 = rgb_to_greyscale(material_4.translucent);
    float _S224 = rgb_to_greyscale(material_4.albedo);
    float _S225 = _S223 / (_S224 + _S223);
    bool _S226 = _S223 > 0.0f;
    float _S227 = _slang_select(_S226, _S225,0.0f);
    return _S227;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S228 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S229 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S230 = 1.0f - lobes_0.translucent_share;
    bool _S231 = n_i_dot_l_0 < 0.0f;
    float _S232 = _slang_select(_S231, lobes_0.translucent_share,_S230);
    float _S233 = _S229 * _S232;
    bool _S234 = (lobes_0.translucent_share) > 0.0f;
    float _S235 = _slang_select(_S234, _S233,_S228);
    bool _S236 = n_i_dot_v_0 > 0.0f;
    float _S237 = _slang_select(_S236, _S235,0.0f);
    return _S237;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_5, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S238 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S239 = _slang_select(_S238, material_5.translucent,material_5.albedo);
    float _S240 = 1.0f - lobes_1.translucent_share;
    float _S241 = _slang_select(_S238, lobes_1.translucent_share,_S240);
    float3  _S242 = _S239 / make_float3 (_S241);
    bool _S243 = (lobes_1.translucent_share) > 0.0f;
    float3  _S244 = _slang_select(_S243, _S242,material_5.albedo);
    return lobes_1.diffuse_weight * _S244 / make_float3 (lobes_1.p_diffuse);
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S245 = smithG1(alpha_6, n_i_dot_v_1);
    float _S246 = _S245 * lobes_2.v_dot_h;
    float _S247 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S248 = _S246 * _S247 / n_i_dot_v_1;
    bool _S249 = alpha_6 > 0.0f;
    bool _S250;
    if(_S249)
    {
        _S250 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S250 = false;
    }
    if(_S250)
    {
        _S250 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S250 = false;
    }
    if(_S250)
    {
        _S250 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S250 = false;
    }
    float _S251 = _slang_select(_S250, _S248,0.0f);
    bool _S252 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S252)
    {
        float _S253 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S254 = (lobes_2.v_dot_h) > 0.0f;
        if(_S254)
        {
            _S250 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S250 = false;
        }
        if(_S250)
        {
            _S250 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S250 = false;
        }
        float _S255 = _slang_select(_S250, _S253,0.0f);
        pdf_h_0 = _S255;
    }
    else
    {
        pdf_h_0 = _S251;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S256 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S257 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S258 = lobes_3.p_refract * _S256 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S257 * _S257);
    bool _S259 = eta_i_4 != eta_o_4;
    bool _S260;
    if(_S259)
    {
        _S260 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S260 = false;
    }
    float _S261 = _slang_select(_S260, _S258,0.0f);
    return _S261;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S262 = - dot_0(n_i_5, l_1);
    float _S263 = smithG1(alpha_8, (F32_max((_S262), (0.0f))));
    bool _S264 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S264)
    {
        float3  _S265 = negate_0(n_i_5);
        float3  _S266 = anisotropicLocal(l_1, lobes_4.tangent, _S265);
        float _S267 = anisotropicG1(_S266, lobes_4.alphas);
        G1_l_0 = _S267;
    }
    else
    {
        G1_l_0 = _S263;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S268 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S269 = n_i_dot_l_2 > 0.0f;
    bool _S270;
    if(_S269)
    {
        _S270 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S270 = false;
    }
    float _S271 = _slang_select(_S270, _S268,0.0f);
    return _S271;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S272 = l_2 + lobes_6.view;
    float3  _S273 = ((((_S272)) * make_float3(rnorm3df(((_S272)).x, ((_S272)).y, ((_S272)).z))));
    float _S274 = dot_0(n_i_6, _S273);
    float _S275 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S276 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S277 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S278 = (2.0f + _S277) * (F32_pow(((F32_max((1.0f - _S274 * _S274), (0.0f)))), (0.5f * _S277))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S275 + _S276 - _S275 * _S276)), (0.0000152587890625f)));
    return lobes_6.sheen * make_float3 (_S278 * _S275 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S279 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    float _S280 = lobes_7.p_reflect * _S279 / (4.0f * lobes_7.v_dot_h);
    bool _S281 = _S279 > 0.0f;
    float _S282 = _slang_select(_S281, _S280,0.0f);
    return _S282;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S283 = dot_0(n_i_7, l_3);
    float _S284 = smithG1(alpha_12, (F32_max((_S283), (0.0f))));
    bool _S285 = (lobes_8.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S285)
    {
        float3  _S286 = anisotropicLocal(l_3, lobes_8.tangent, n_i_7);
        float _S287 = anisotropicG1(_S286, lobes_8.alphas);
        G1_l_1 = _S287;
    }
    else
    {
        G1_l_1 = _S284;
    }
    return make_float3 (lobes_8.reflect_weight * G1_l_1) * lobes_8.F / make_float3 (lobes_8.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_8, BSDFMaterial material_9, float eta_i_7, float eta_o_7, bool refracted_1, uint random_state_2, FixedArray<float3 , 4>  * throughputs_0, FixedArray<float, 4>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S288 = negate_0(in_dir_4);
    float _S289 = dot_0(n_8, _S288);
    float _S290 = sign_0(_S289);
    float3  _S291 = n_8 * make_float3 (_S290);
    AnisotropicFrame _S292 = anisotropicFrame(material_9, _S291);
    float _S293 = dot_0(_S291, out_dir_2);
    float _S294 = material_9.roughness;
    float _S295 = _S294 * _S294;
    SheenProfile _S296 = sheenProfile(_S288, _S291, material_9);
    float _S297 = rgb_to_greyscale(material_9.translucent);
    bool _S298 = _S297 > 0.0f;
    bool _S299 = (dot_0(n_8, out_dir_2) * _S289) < 0.0f;
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
        float3  _S300 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S300;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S301 = make_float3 (0.0f);
    BSDFLobes _S302 = BSDFLobes_x24init_0(0.0f, 0.0f, _S301, _S301, 0.0f, 0.0f, _S301, _S301, 0.0f, 0.0f, 0.0f, 0.0f, _S301, 0.0f, _S301, _S301, make_float2 (0.0f), 0.0f);
    BSDFLobes lobe_terms_0 = _S302;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S301;
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
        uint _S303;
        if(i_10 == 3U)
        {
            _S303 = 4U;
        }
        else
        {
            _S303 = i_10;
        }
        bool _S304 = _S303 == 0U;
        bool _S305;
        if(_S304)
        {
            _S305 = _S298;
        }
        else
        {
            _S305 = false;
        }
        bool _S306;
        if(_S305)
        {
            _S306 = _S299;
        }
        else
        {
            _S306 = _S303 == 1U;
        }
        bool _S307 = _S306 != refracted_1;
        if(_S307)
        {
            ggx_n_1 = ggx_n_2;
            uint i_12 = i_10 + 1U;
            ggx_n_2 = ggx_n_1;
            i_10 = i_12;
            continue;
        }
        uint _S308;
        if(_S303 == 4U)
        {
            _S308 = 2U;
        }
        else
        {
            _S308 = _S303;
        }
        bool _S309 = _S308 != half_of_0;
        uint half_of_1;
        if(_S309)
        {
            bool _S310 = _S308 == 0U;
            if(_S310)
            {
                float3  _S311 = sampledHalf(in_dir_4, n_8, material_9, random_state_2, _S292);
                ggx_n_1 = _S311;
            }
            else
            {
                bool _S312 = _S308 == 1U;
                if(_S312)
                {
                    float3  _S313 = refractedHalf(in_dir_4, out_dir_2, n_8, eta_i_7, eta_o_7);
                    ggx_n_1 = _S313;
                }
                else
                {
                    float3  _S314 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S314;
                }
            }
            float3  _S315 = negate_0(in_dir_4);
            BSDFLobes _S316 = bsdfLobes(in_dir_4, _S315, _S291, ggx_n_1, material_9, eta_i_7, eta_o_7, _S292, _S296);
            lobe_terms_0 = _S316;
            float _S317 = translucentShare(material_9);
            (&lobe_terms_0)->translucent_share = _S317;
            half_of_1 = _S308;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S303)
        {
        case 0U:
            {
                float _S318 = diffusePDF(_S293, 0.0f, (F32_abs((_S289))), _S295, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(0)] = _S318;
                float3  _S319 = diffuseBSDF(out_dir_2, _S291, _S295, material_9, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S319;
                break;
            }
        case 1U:
            {
                float _S320 = refractPDF(_S293, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S289))), _S295, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(1)] = _S320;
                float3  _S321 = refractBSDF(out_dir_2, _S291, _S295, material_9, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S321;
                break;
            }
        case 4U:
            {
                float _S322 = sheenVelvetPDF(_S293, 0.0f, (F32_abs((_S289))), _S295, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(3)] = _S322;
                float3  _S323 = sheenVelvetBSDF(out_dir_2, _S291, _S295, material_9, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S323;
                break;
            }
        default:
            {
                float _S324 = reflectPDF(_S293, 0.0f, (F32_abs((_S289))), _S295, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(2)] = _S324;
                float3  _S325 = reflectBSDF(out_dir_2, _S291, _S295, material_9, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S325;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_12 = i_10 + 1U;
        ggx_n_2 = ggx_n_1;
        i_10 = i_12;
    }
    i_10 = 0U;
    ggx_n_1 = _S301;
    for(;;)
    {
        if(i_10 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S326 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S326)
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
    SampleBSDF _S327;
    (&_S327)->unit_direction = unit_direction_0;
    (&_S327)->throughput = throughput_0;
    (&_S327)->random_state = random_state_3;
    (&_S327)->refracted = refracted_2;
    (&_S327)->lobe = lobe_0;
    (&_S327)->pdf = pdf_0;
    return _S327;
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_0, float3  n_i_8, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_10, BSDFLobes lobes_9, float eta_i_8, float eta_o_8, uint random_state_4)
{
    float3  _S328 = make_float3 (1.0f);
    SampleBSDF _S329 = SampleBSDF_x24init_0(_S328, _S328, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S329;
    Random _S330 = pcg(random_state_4);
    Random _S331 = pcg(_S330.state);
    (&sample_0)->random_state = _S331.state;
    float3  _S332 = sampleCosWeightedHemisphere(_S330.value, _S331.value);
    bool _S333 = u_0 < (lobes_9.p_diffuse * lobes_9.translucent_share);
    float _S334 = _S332.y;
    float _S335 = - _S334;
    float _S336 = _slang_select(_S333, _S335,_S334);
    float3  _S337 = tangentToWorld(make_float3 (_S332.x, _S336, _S332.z), n_i_8);
    (&sample_0)->unit_direction = _S337;
    (&sample_0)->refracted = _S333;
    (&sample_0)->lobe = 0U;
    float3  _S338 = diffuseBSDF((&sample_0)->unit_direction, n_i_8, alpha_13, material_10, lobes_9);
    (&sample_0)->throughput = _S338;
    float _S339 = diffusePDF(_S336, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_8, eta_o_8);
    (&sample_0)->pdf = _S339;
    return sample_0;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_11, BSDFLobes lobes_10, float eta_i_9, float eta_o_9, uint random_state_5)
{
    float3  _S340 = make_float3 (1.0f);
    SampleBSDF _S341 = SampleBSDF_x24init_0(_S340, _S340, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S341;
    Random _S342 = pcg(random_state_5);
    Random _S343 = pcg(_S342.state);
    (&sample_1)->random_state = _S343.state;
    float _S344 = _S342.value;
    float _S345 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S344 * _S344))))));
    float _S346 = 6.28318548202514648f * _S343.value;
    float3  _S347 = tangentToWorld(make_float3 (_S345 * (F32_cos((_S346))), _S342.value, _S345 * (F32_sin((_S346)))), n_i_9);
    (&sample_1)->unit_direction = _S347;
    (&sample_1)->lobe = 4U;
    float3  _S348 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_14, material_11, lobes_10);
    (&sample_1)->throughput = _S348;
    float _S349 = sheenVelvetPDF(_S342.value, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_9, eta_o_9);
    (&sample_1)->pdf = _S349;
    return sample_1;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_10, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_12, BSDFLobes lobes_11, float eta_i_10, float eta_o_10, uint random_state_6)
{
    float3  _S350 = make_float3 (1.0f);
    SampleBSDF _S351 = SampleBSDF_x24init_0(_S350, _S350, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S351;
    (&sample_2)->unit_direction = lobes_11.refracted;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->refracted = true;
    (&sample_2)->lobe = 1U;
    float3  _S352 = refractBSDF((&sample_2)->unit_direction, n_i_10, alpha_15, material_12, lobes_11);
    (&sample_2)->throughput = _S352;
    float _S353 = refractPDF(0.0f, dot_0((&sample_2)->unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_10, eta_o_10);
    (&sample_2)->pdf = _S353;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_11, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_13, BSDFLobes lobes_12, float eta_i_11, float eta_o_11, uint random_state_7)
{
    float3  _S354 = make_float3 (1.0f);
    SampleBSDF _S355 = SampleBSDF_x24init_0(_S354, _S354, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S355;
    float3  _S356 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S357 = ((((_S356)) * make_float3(rnorm3df(((_S356)).x, ((_S356)).y, ((_S356)).z))));
    (&sample_3)->unit_direction = _S357;
    (&sample_3)->random_state = random_state_7;
    (&sample_3)->lobe = 2U;
    float3  _S358 = reflectBSDF((&sample_3)->unit_direction, n_i_11, alpha_16, material_13, lobes_12);
    (&sample_3)->throughput = _S358;
    float _S359 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_11, eta_o_11);
    (&sample_3)->pdf = _S359;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_9, BSDFMaterial material_14, float eta_i_12, float eta_o_12, uint random_init_0, float2  screen_space_0)
{
    uint random_state_8 = random_init_0;
    float3  _S360 = negate_0(in_dir_6);
    float _S361 = dot_0(n_9, _S360);
    float _S362 = sign_0(_S361);
    float3  n_i_12 = n_9 * make_float3 (_S362);
    float _S363 = (F32_abs((_S361)));
    float _S364 = material_14.roughness;
    float _S365 = _S364 * _S364;
    AnisotropicFrame _S366 = anisotropicFrame(material_14, n_i_12);
    SheenProfile _S367 = sheenProfile(_S360, n_i_12, material_14);
    float3  _S368 = sampleHalfVector(_S360, n_i_12, _S365, _S366, &random_state_8);
    BSDFLobes _S369 = bsdfLobes(in_dir_6, _S360, n_i_12, _S368, material_14, eta_i_12, eta_o_12, _S366, _S367);
    BSDFLobes lobes_13 = _S369;
    float _S370 = translucentShare(material_14);
    (&lobes_13)->translucent_share = _S370;
    Random _S371 = pcg(random_state_8);
    random_state_8 = _S371.state;
    bool _S372 = (_S371.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S372)
    {
        SampleBSDF _S373 = sheenVelvetSample(n_i_12, _S363, _S365, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S373;
    }
    float _S374 = _S371.value - (&lobes_13)->p_sheen_velvet;
    bool _S375 = _S374 < ((&lobes_13)->p_diffuse);
    if(_S375)
    {
        SampleBSDF _S376 = diffuseSample(_S374, n_i_12, _S363, _S365, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S376;
    }
    bool _S377 = _S374 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S377)
    {
        SampleBSDF _S378 = refractSample(_S368, n_i_12, _S363, _S365, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S378;
    }
    SampleBSDF _S379 = reflectSample(in_dir_6, _S368, n_i_12, _S363, _S365, material_14, lobes_13, eta_i_12, eta_o_12, random_state_8);
    return _S379;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S380 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S380));
}

__device__ float2  vertexEta(BSDFMaterial material_15, float n_dot_v_0)
{
    bool _S381 = n_dot_v_0 < 0.0f;
    float _S382 = _slang_select(_S381, material_15.ior,1.0f);
    float _S383 = _slang_select(_S381, 1.0f,material_15.ior);
    return make_float2 (_S382, _S383);
}

__device__ bool neeDecision(BSDFMaterial material_16, float n_dot_v_1, float eta_i_13, float eta_o_13)
{
    float _S384 = fresnel((F32_abs((n_dot_v_1))), eta_i_13, eta_o_13);
    float3  _S385 = mix_0(make_float3 (_S384), material_16.albedo, material_16.metallic);
    float _S386 = rgb_to_greyscale(_S385);
    float _S387 = (F32_max(((1.0f - _S386) * (1.0f - material_16.metallic) * (1.0f - material_16.transmission)), (0.0f)));
    bool _S388 = _S387 > 0.03999999910593033f;
    bool _S389;
    if(_S388)
    {
        _S389 = true;
    }
    else
    {
        _S389 = (material_16.roughness) > 0.20000000298023224f;
    }
    return _S389;
}

__device__ float3  straightThrough(BSDFMaterial material_17)
{
    return make_float3 (material_17.transmission * (1.0f - material_17.metallic)) * material_17.albedo;
}

__device__ float hairRow(float3  in_dir_7, float3  t_3, float3  out_dir_3, uint p_0, float w_2, float alpha_17, uint nt_0)
{
    uint _S390 = p_0 % 4U;
    float _S391 = w_2 * HAIR_WIDTHS_0[_S390];
    float _S392 = (F32_asin((clamp_1(dot_0(out_dir_3, t_3), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_7, t_3), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S390] * alpha_17;
    return ((F32_asinh((_S392 / _S391))) / (F32_asinh((3.14159274101257324f / _S391))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_8, float3  t_4, float3  out_dir_4, uint np_0)
{
    float3  _S393 = worldToTangent(out_dir_4, t_4);
    float3  _S394 = worldToTangent(in_dir_8, t_4);
    return (F32_frac((((F32_atan2((_S393.z), (_S393.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S394.z), (1.17549435082228751e-38f - _S394.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_9, float3  t_5, uint p_1, float row_0, float column_0, float w_3, float alpha_18, uint nt_1, uint np_1)
{
    float3  _S395 = worldToTangent(in_dir_9, t_5);
    uint _S396 = p_1 % 4U;
    float _S397 = w_3 * HAIR_WIDTHS_0[_S396];
    float _S398 = (F32_asin((clamp_1(dot_0(in_dir_9, t_5), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S396] * alpha_18 + _S397 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S397))))));
    float _S399 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S395.z), (1.17549435082228751e-38f - _S395.x)));
    float _S400 = (F32_cos((_S398)));
    float3  _S401 = tangentToWorld(make_float3 (_S400 * (F32_cos((_S399))), (F32_sin((_S398))), _S400 * (F32_sin((_S399)))), t_5);
    return _S401;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S402 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S402 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_10, BSDFMaterial material_18, float coverage_0)
{
    float3  _S403;
    if((material_18.ior) == 1.0f)
    {
        float3  _S404 = straightThrough(material_18);
        _S403 = _S404;
    }
    else
    {
        _S403 = make_float3 (0.0f);
    }
    return _S403 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S405 = hash(index_0);
    uint _S406 = hash(seed_0 ^ _S405);
    return _S406;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S407 = a_4 / b_0;
    float3  _S408 = make_float3 (0.0f);
    bool3  _S409 = b_0 == _S408;
    float3  _S410 = _slang_select(_S409, _S408,_S407);
    return _S410;
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
    float _S411 = rgb_to_greyscale(weight_0);
    bool _S412 = _S411 > 0.0f;
    bool _S413;
    if(_S412)
    {
        _S413 = _S411 < 3.00000000549775576e+38f;
    }
    else
    {
        _S413 = false;
    }
    bool _S414 = !_S413;
    if(_S414)
    {
        return;
    }
    float _S415 = sel_0->w_sum + _S411;
    sel_0->w_sum = _S415;
    float3  _S416 = sel_0->color + weight_0;
    sel_0->color = _S416;
    Random _S417 = pcg(sel_0->random_state);
    sel_0->random_state = _S417.state;
    bool _S418 = (_S417.value * sel_0->w_sum) <= _S411;
    if(_S418)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S419 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S419;
    float _S420 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S420;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S421 = rgb_to_greyscale((&r_1)->f);
    float _S422 = sel_2.w_sum / _S421;
    bool _S423 = _S421 > 0.0f;
    float _S424 = _slang_select(_S423, _S422,0.0f);
    (&r_1)->w = _S424;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S425 = (1U << count_0) - 1U;
    return (e_1 & (~(_S425 << offset_0))) | ((newbits_0 & _S425) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S426 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S427 = insertBits_0(_S426, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S427;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S428 = transmission_0 > 0.0f;
    bool _S429;
    if(_S428)
    {
        _S429 = true;
    }
    else
    {
        _S429 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S430;
    if(_S429)
    {
        _S430 = 1.0f;
    }
    else
    {
        _S430 = -1.0f;
    }
    return _S430;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S431 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S432 = cos_a_0 > cos_b_0;
    float _S433 = _slang_select(_S432, 1.0f,_S431);
    return _S433;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_2, float3  normal_0)
{
    float3  _S434 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S435 = node_0.high - node_0.low;
    float3  _S436 = p_2 - _S434;
    float3  _S437 = ((((_S436)) * make_float3(rnorm3df(((_S436)).x, ((_S436)).y, ((_S436)).z))));
    float _S438 = dot_0(_S436, _S436);
    float _S439 = dot_0(_S435, _S435) / 4.0f;
    float _S440 = (F32_abs((dot_0(node_0.w, _S437))));
    float _S441 = sine(node_0.cos_theta_o);
    float _S442 = (F32_sqrt(((F32_max((1.0f - _S439 / _S438), (0.0f))))));
    bool _S443 = _S438 < _S439;
    float _S444 = _slang_select(_S443, -1.0f,_S442);
    float _S445 = sine(_S444);
    float _S446 = sine(_S440);
    float _S447 = cosSubClamped(_S446, _S440, _S441, node_0.cos_theta_o);
    float _S448 = sine(_S440);
    float _S449 = _S448 * node_0.cos_theta_o - _S440 * _S441;
    bool _S450 = _S440 > (node_0.cos_theta_o);
    float _S451 = _slang_select(_S450, 0.0f,_S449);
    float _S452 = cosSubClamped(_S451, _S447, _S445, _S444);
    bool _S453 = _S452 <= 0.0f;
    if(_S453)
    {
        return 0.0f;
    }
    float _S454 = - dot_0(_S437, normal_0);
    float _S455 = node_0.phi * _S452 / (F32_max((_S438), (length_0(_S435) / 2.0f)));
    float _S456 = sine(_S454);
    float _S457 = cosSubClamped(_S456, _S454, _S445, _S444);
    bool _S458 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S459 = _slang_select(_S458, 1.0f,_S457);
    return (F32_max((_S455 * _S459), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_3, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S460 = importance(first_0, p_3, normal_2);
    float _S461 = importance(second_0, p_3, normal_2);
    float2  _S462 = make_float2 (_S460, _S461);
    bool _S463 = _S460 == 0.0f;
    bool _S464;
    if(_S463)
    {
        _S464 = _S461 == 0.0f;
    }
    else
    {
        _S464 = false;
    }
    if(_S464)
    {
        return 2U;
    }
    float _S465 = _S460 + _S461;
    bool _S466 = _S461 > 0.0f;
    if(_S466)
    {
        _S464 = (*pick_0 * _S465) >= _S460;
    }
    else
    {
        _S464 = false;
    }
    uint _S467 = uint(_S464);
    float _S468 = (F32_min(((*pick_0 * _S465 - float(_S467) * _S460) / _slang_vector_get_element(_S462, _S467)), (0.99999994039535522f)));
    *pick_0 = _S468;
    float _S469 = *probability_1 * (_slang_vector_get_element(_S462, _S467) / _S465);
    *probability_1 = _S469;
    return _S467;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_4, float3  normal_3, uint child_0)
{
    float _S470 = importance(first_1, p_4, normal_3);
    float _S471 = importance(second_1, p_4, normal_3);
    float2  _S472 = make_float2 (_S470, _S471);
    float _S473 = _slang_vector_get_element(_S472, child_0) / (_S470 + _S471);
    bool _S474 = _slang_vector_get_element(_S472, child_0) > 0.0f;
    float _S475 = _slang_select(_S474, _S473,0.0f);
    return _S475;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S476 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S477 = b_1 > 0.0f;
    float _S478 = _slang_select(_S477, _S476,1.0f);
    return _S478;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_5)
{
    float3  _S479 = center_0 - p_5;
    float _S480 = radius_1 * radius_1 / dot_0(_S479, _S479);
    bool _S481 = _S480 >= 1.0f;
    if(_S481)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S480)))) / (6.28318548202514648f * _S480);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_6, float u1_0, float u2_0)
{
    float3  _S482 = center_1 - p_6;
    float _S483 = radius_2 * radius_2 / dot_0(_S482, _S482);
    float _S484 = u1_0 * _S483 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S483), (0.0f)))))));
    float _S485 = 2.0f * u1_0;
    bool _S486 = _S483 >= 1.0f;
    float _S487 = _slang_select(_S486, _S485,_S484);
    float _S488 = (F32_sqrt(((F32_max((_S487 * (2.0f - _S487)), (0.0f))))));
    float _S489 = 6.28318548202514648f * u2_0;
    float3  _S490 = make_float3 (_S488 * (F32_cos((_S489))), 1.0f - _S487, _S488 * (F32_sin((_S489))));
    float3  _S491 = ((((_S482)) * make_float3(rnorm3df(((_S482)).x, ((_S482)).y, ((_S482)).z))));
    float3  _S492 = tangentToWorld(_S490, _S491);
    return _S492;
}

#undef Matrix
