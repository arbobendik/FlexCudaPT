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

__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
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

static __device__ float random_0(uint * state_1)
{
    uint _S12 = hash(*state_1);
    *state_1 = _S12;
    return float((*state_1) >> int(8)) * 5.9604644775390625e-08f;
}

__device__ Random pcg(uint state_2)
{
    uint _S13 = state_2;
    float value_1 = random_0(&_S13);
    return Random_x24init_0(_S13, value_1);
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S14 = pcg(state_3);
    Random _S15 = pcg(_S14.state);
    float _S16 = 6.28318548202514648f * _S14.value;
    float _S17 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S15.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S15.state, _S17 * (F32_cos((_S16))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S18;
    (&_S18)->state = state_4;
    (&_S18)->value = value_2;
    return _S18;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S19 = normal_distribution(state_5);
    Random _S20 = normal_distribution(_S19.state);
    Random _S21 = normal_distribution(_S20.state);
    float3  _S22 = make_float3 (_S19.value, _S20.value, _S21.value);
    float3  _S23 = ((((_S22)) * make_float3(rnorm3df(((_S22)).x, ((_S22)).y, ((_S22)).z))));
    return RandomSphere_x24init_0(_S21.state, _S23);
}

struct RandomHemisphere
{
    uint state;
    float3  value;
};

static __device__ RandomHemisphere RandomHemisphere_x24init_0(uint state_6, float3  value_3)
{
    RandomHemisphere _S24;
    (&_S24)->state = state_6;
    (&_S24)->value = value_3;
    return _S24;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

__device__ RandomHemisphere random_hemisphere(uint state_7, float3  normal_0)
{
    RandomSphere _S25 = random_sphere(state_7);
    bool _S26 = (dot_0(_S25.value, normal_0)) > 0.0f;
    if(_S26)
    {
        return RandomHemisphere_x24init_0(_S25.state, _S25.value);
    }
    else
    {
        float3  _S27 = negate_0(_S25.value);
        return RandomHemisphere_x24init_0(_S25.state, _S27);
    }
}

__device__ float trowbridgeReitz(float alpha_0, float n_dot_h_0)
{
    float _S28 = alpha_0 * alpha_0;
    float _S29 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S28 * n_dot_h_0 * n_dot_h_0;
    return _S28 / (F32_max((3.14159274101257324f * _S29 * _S29), (1.17549435082228751e-38f)));
}

__device__ float smithG1(float alpha_1, float n_dot_x_0)
{
    float _S30 = alpha_1 * alpha_1;
    float _S31 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S30 + (1.0f - _S30) * n_dot_x_0 * n_dot_x_0))));
    bool _S32 = alpha_1 > 0.0f;
    float _S33 = _slang_select(_S32, _S31,1.0f);
    return _S33;
}

__device__ float G1(float alpha_2, float n_dot_x_1)
{
    float _S34 = smithG1(alpha_2, n_dot_x_1);
    return _S34;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S35 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S36 = eta_i_0 / eta_o_0 * _S35;
    bool _S37 = _S36 < 1.0f;
    float kr_0;
    if(_S37)
    {
        float _S38 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S36 * _S36))))));
        float _S39 = eta_o_0 * cos_theta_0;
        float _S40 = eta_i_0 * _S38;
        float _S41 = (_S39 - _S40) / (_S39 + _S40);
        float _S42 = eta_i_0 * cos_theta_0;
        float _S43 = eta_o_0 * _S38;
        float _S44 = (_S42 - _S43) / (_S42 + _S43);
        float _S45 = (_S41 * _S41 + _S44 * _S44) / 2.0f;
        kr_0 = _S45;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float unshared_0(float x_14)
{
    return x_14;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_3, float U1_0, float U2_0)
{
    float3  _S46 = make_float3 (alpha_3 * Ve_0.x, alpha_3 * Ve_0.y, Ve_0.z);
    float3  _S47 = ((((_S46)) * make_float3(rnorm3df(((_S46)).x, ((_S46)).y, ((_S46)).z))));
    float _S48 = _S47.x;
    float _S49 = _S47.y;
    float _S50 = _S48 * _S48 + _S49 * _S49;
    float3  _S51;
    if(_S50 > 0.0f)
    {
        float3  _S52 = make_float3 (- _S49, _S48, 0.0f);
        float _S53 = (rsqrtf((_S50)));
        _S51 = _S52 * make_float3 (_S53);
    }
    else
    {
        _S51 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S54 = cross_0(_S47, _S51);
    float _S55 = (F32_sqrt((U1_0)));
    float _S56 = 6.28318548202514648f * U2_0;
    float _S57 = _S55 * (F32_cos((_S56)));
    float t2_0 = _S55 * (F32_sin((_S56)));
    float _S58 = 0.5f * (1.0f + _S47.z);
    float t2_1 = (1.0f - _S58) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S57 * _S57)))))) + _S58 * t2_0;
    float3  _S59 = make_float3 (_S57) * _S51 + make_float3 (t2_1) * _S54;
    float _S60 = unshared_0(_S57);
    float _S61 = unshared_0(_S57);
    float3  _S62 = _S59 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S60 * _S61 - t2_1 * t2_1))))))) * _S47;
    float3  _S63 = make_float3 (alpha_3 * _S62.x, alpha_3 * _S62.y, (F32_max((0.0f), (_S62.z))));
    float3  _S64 = ((((_S63)) * make_float3(rnorm3df(((_S63)).x, ((_S63)).y, ((_S63)).z))));
    return _S64;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S65 = (F32_sqrt((random_1_0)));
    float _S66 = 6.28318548202514648f * random_2_0;
    float _S67 = _S65 * (F32_cos((_S66)));
    float _S68 = _S65 * (F32_sin((_S66)));
    float _S69 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S67 * _S67 - _S68 * _S68))))));
    return make_float3 (_S67, _S69, _S68);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S70 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S70)
    {
        float3  _S71 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S71;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S72 = cross_0(n_2, a_1);
    float3  _S73 = ((((_S72)) * make_float3(rnorm3df(((_S72)).x, ((_S72)).y, ((_S72)).z))));
    float3  _S74 = cross_0(n_2, _S73);
    return make_float3 (v_0.x) * _S73 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S74;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S75 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S75)
    {
        float3  _S76 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S76;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S77 = cross_0(n_3, a_3);
    float3  _S78 = ((((_S77)) * make_float3(rnorm3df(((_S77)).x, ((_S77)).y, ((_S77)).z))));
    float3  _S79 = cross_0(n_3, _S78);
    return make_float3 (dot_0(v_1, _S78), dot_0(v_1, n_3), dot_0(v_1, _S79));
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S80 = p1_0 - p0_0;
    float3  _S81 = p2_0 - p0_0;
    float2  _S82 = uv1_0 - uv0_0;
    float2  _S83 = uv2_0 - uv0_0;
    float _S84 = _S82.x;
    float _S85 = _S83.y;
    float _S86 = _S82.y;
    float _S87 = _S83.x;
    float _S88 = _S84 * _S85 - _S86 * _S87;
    float _S89 = 1.0f / _S88;
    float3  t_0 = (_S80 * make_float3 (_S85) - _S81 * make_float3 (_S86)) * make_float3 (_S89);
    float3  _S90 = (_S81 * make_float3 (_S84) - _S80 * make_float3 (_S87)) * make_float3 (_S89);
    float3  _S91 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  t_1 = ((((_S91)) * make_float3(rnorm3df(((_S91)).x, ((_S91)).y, ((_S91)).z))));
    bool _S92 = (dot_0(cross_0(n_4, t_1), _S90)) > 0.0f;
    float3  t_2;
    if(_S92)
    {
        float3  _S93 = negate_0(t_1);
        t_2 = _S93;
    }
    else
    {
        t_2 = t_1;
    }
    float3  _S94 = cross_0(n_4, t_2);
    return makeMatrix<float, 3, 3> (t_2, _S94, n_4);
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

__device__ float3  sampleHalfVector(float3  v_3, float3  n_i_0, float alpha_4, uint * random_state_0)
{
    Random _S107 = pcg(*random_state_0);
    Random _S108 = pcg(_S107.state);
    *random_state_0 = _S108.state;
    float3  _S109 = worldToTangent(v_3, n_i_0);
    float3  _S110 = sampleGGXVNDF(float3 {_S109.x, _S109.z, _S109.y}, alpha_4, _S107.value, _S108.value);
    float3  _S111 = float3 {_S110.x, _S110.z, _S110.y};
    float3  _S112 = tangentToWorld(_S111, n_i_0);
    return _S112;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ float sign_0(float e_0)
{
    float _S113;
    if(e_0 > 0.0f)
    {
        _S113 = 1.0f;
    }
    else
    {
        if(e_0 < 0.0f)
        {
            _S113 = -1.0f;
        }
        else
        {
            _S113 = 0.0f;
        }
    }
    return _S113;
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
    float3  view;
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_1, float3  refracted_0, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float3  view_0)
{
    BSDFLobes _S114;
    (&_S114)->v_dot_h = v_dot_h_0;
    (&_S114)->n_dot_h = n_dot_h_1;
    (&_S114)->refracted = refracted_0;
    (&_S114)->F = F_0;
    (&_S114)->F_greyscale = F_greyscale_0;
    (&_S114)->reflect_weight = reflect_weight_0;
    (&_S114)->diffuse_weight = diffuse_weight_0;
    (&_S114)->refract_weight = refract_weight_0;
    (&_S114)->p_diffuse = p_diffuse_0;
    (&_S114)->p_reflect = p_reflect_0;
    (&_S114)->p_refract = p_refract_0;
    (&_S114)->translucent_share = translucent_share_0;
    (&_S114)->sheen = sheen_0;
    (&_S114)->view = view_0;
    return _S114;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_0, float3  v_4, float3  n_i_1, float3  ggx_n_0, BSDFMaterial material_0, float eta_i_1, float eta_o_1)
{
    float _S115 = dot_0(ggx_n_0, v_4);
    float _S116 = dot_0(n_i_1, ggx_n_0);
    float _S117 = eta_i_1 / eta_o_1;
    float3  _S118 = refract_0(in_dir_0, ggx_n_0, _S117);
    float3  _S119 = ((((_S118)) * make_float3(rnorm3df(((_S118)).x, ((_S118)).y, ((_S118)).z))));
    float _S120 = (F32_min(((F32_sqrt((material_0.specular_level))) * (F32_abs((eta_i_1 - eta_o_1))) / (eta_i_1 + eta_o_1)), (0.9999847412109375f)));
    float _S121 = _S120 * _S120;
    float _S122 = (1.0f + _S120) / (1.0f - _S120);
    float _S123 = (F32_abs((_S115)));
    bool _S124 = eta_i_1 > eta_o_1;
    float _S125;
    if(_S124)
    {
        _S125 = _S122;
    }
    else
    {
        _S125 = 1.0f;
    }
    float _S126;
    if(_S124)
    {
        _S126 = 1.0f;
    }
    else
    {
        _S126 = _S122;
    }
    float _S127 = fresnel(_S123, _S125, _S126);
    bool _S128 = (eta_i_1 * eta_i_1 * (1.0f - _S115 * _S115)) >= (eta_o_1 * eta_o_1);
    float3  _S129;
    if(_S128)
    {
        _S129 = make_float3 (1.0f);
    }
    else
    {
        float3  _S130 = material_0.specular_tint * make_float3 (_S121);
        _S129 = _S130 + (make_float3 (1.0f) - _S130) * make_float3 (_S127 - _S121) / make_float3 (1.0f - _S121);
    }
    float3  F_1 = mix_0(_S129, material_0.albedo, material_0.metallic);
    float _S131 = rgb_to_greyscale(F_1);
    float _S132 = 1.0f - material_0.metallic;
    float3  _S133 = make_float3 (1.0f) - _S129;
    float3  _S134 = make_float3 ((1.0f - material_0.transmission) * _S132) * _S133;
    float3  _S135 = make_float3 (material_0.transmission * _S132) * _S133;
    float _S136 = (F32_max((_S131), (0.0f)));
    float _S137 = rgb_to_greyscale(_S134);
    float _S138 = (F32_max((_S137), (0.0f)));
    float _S139 = rgb_to_greyscale(_S135);
    float _S140 = sign_0(length_0(_S119));
    float _S141 = (F32_max((_S139 * _S140), (0.0f)));
    float _S142 = _S136 + _S138 + _S141;
    float _S143 = 1.0f / (F32_max((_S142), (0.0000152587890625f)));
    float _S144 = _S138 * _S143;
    float _S145 = _S136 * _S143;
    float _S146 = _S141 * _S143;
    float3  _S147 = make_float3 (0.0f);
    return BSDFLobes_x24init_0(_S115, _S116, _S119, F_1, _S131, 1.0f, _S134, _S135, _S144, _S145, _S146, 0.0f, _S147, _S147);
}

__device__ float translucentShare(BSDFMaterial material_1)
{
    float _S148 = rgb_to_greyscale(material_1.translucent);
    float _S149 = rgb_to_greyscale(material_1.albedo);
    float _S150 = _S148 / (_S149 + _S148);
    bool _S151 = _S148 > 0.0f;
    float _S152 = _slang_select(_S151, _S150,0.0f);
    return _S152;
}

__device__ __noinline__ float sheenAlbedo(float mu_0, float r_0)
{
    float _S153 = (F32_sqrt((0.05000000074505806f)));
    float _S154 = clamp_1((F32_sqrt(((F32_max((mu_0), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
    float _S155 = (clamp_1((F32_sqrt(((F32_max((r_0), (0.0f)))))), _S153, 1.0f) - _S153) / (1.0f - _S153) * 23.0f;
    uint _S156 = (U32_min((uint(_S154)), (22U)));
    uint _S157 = (U32_min((uint(_S155)), (22U)));
    float _S158 = _S154 - float(_S156);
    float _S159 = _S155 - float(_S157);
    uint _S160 = _S156 * 24U + _S157;
    uint _S161 = _S160 + 24U;
    float _S162 = SHEEN_ALBEDO_0[_S160] + (SHEEN_ALBEDO_0[_S161] - SHEEN_ALBEDO_0[_S160]) * _S158;
    uint _S163 = _S160 + 1U;
    float _S164 = SHEEN_ALBEDO_0[_S163] + (SHEEN_ALBEDO_0[_S161 + 1U] - SHEEN_ALBEDO_0[_S163]) * _S158;
    return (F32_exp((_S162 + (_S164 - _S162) * _S159)));
}

__device__ BSDFLobes sheenLobes(BSDFLobes lobes_0, float3  v_5, float n_i_dot_v_0, BSDFMaterial material_2)
{
    float _S165 = rgb_to_greyscale(material_2.sheen);
    BSDFLobes sheened_0 = lobes_0;
    bool _S166 = _S165 > 0.0f;
    if(_S166)
    {
        float _S167 = sheenAlbedo(n_i_dot_v_0, material_2.sheen_roughness);
        float _S168 = (F32_min((_S167), (1.0f)));
        float3  _S169 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S168);
        float3  _S170 = lobes_0.F * _S169;
        float _S171 = rgb_to_greyscale(_S170);
        float _S172 = (F32_max((lobes_0.reflect_weight * _S171), (0.0f)));
        float3  _S173 = lobes_0.diffuse_weight * _S169;
        float _S174 = rgb_to_greyscale(_S173);
        float _S175 = (F32_max((_S174), (0.0f)));
        float3  _S176 = lobes_0.refract_weight * _S169;
        float _S177 = rgb_to_greyscale(_S176);
        float _S178 = sign_0(length_0(lobes_0.refracted));
        float _S179 = (F32_max((_S177 * _S178), (0.0f)));
        float _S180 = _S165 * _S168;
        float _S181 = 1.0f / (F32_max((_S172 + _S175 + _S179 + _S180), (0.0000152587890625f)));
        (&sheened_0)->F = _S170;
        float _S182 = rgb_to_greyscale((&sheened_0)->F);
        (&sheened_0)->F_greyscale = _S182;
        (&sheened_0)->diffuse_weight = _S173;
        (&sheened_0)->refract_weight = _S176;
        float _S183 = (_S175 + _S180) * _S181;
        (&sheened_0)->p_diffuse = _S183;
        float _S184 = _S172 * _S181;
        (&sheened_0)->p_reflect = _S184;
        float _S185 = _S179 * _S181;
        (&sheened_0)->p_refract = _S185;
        float3  _S186 = material_2.sheen / make_float3 ((F32_max((_S167), (1.0f))));
        (&sheened_0)->sheen = _S186;
        (&sheened_0)->view = v_5;
    }
    return sheened_0;
}

__device__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_1, float alpha_5, BSDFLobes lobes_1, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S187 = lobe_0 == 0U;
    if(_S187)
    {
        float _S188 = lobes_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S189 = lobes_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S190 = 1.0f - lobes_1.translucent_share;
        bool _S191 = n_i_dot_l_0 < 0.0f;
        float _S192 = _slang_select(_S191, lobes_1.translucent_share,_S190);
        float _S193 = _S189 * _S192;
        bool _S194 = (lobes_1.translucent_share) > 0.0f;
        float _S195 = _slang_select(_S194, _S193,_S188);
        bool _S196 = n_i_dot_v_1 > 0.0f;
        float _S197 = _slang_select(_S196, _S195,0.0f);
        return _S197;
    }
    float _S198 = smithG1(alpha_5, n_i_dot_v_1);
    float _S199 = _S198 * lobes_1.v_dot_h;
    float _S200 = trowbridgeReitz(alpha_5, lobes_1.n_dot_h);
    float _S201 = _S199 * _S200 / n_i_dot_v_1;
    bool _S202 = alpha_5 > 0.0f;
    bool _S203;
    if(_S202)
    {
        _S203 = (lobes_1.v_dot_h) > 0.0f;
    }
    else
    {
        _S203 = false;
    }
    if(_S203)
    {
        _S203 = (lobes_1.n_dot_h) > 0.0f;
    }
    else
    {
        _S203 = false;
    }
    if(_S203)
    {
        _S203 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S203 = false;
    }
    float _S204 = _slang_select(_S203, _S201,0.0f);
    bool _S205 = lobe_0 == 1U;
    if(_S205)
    {
        float _S206 = eta_i_2 * lobes_1.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S207 = lobes_1.p_refract * _S204 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S206 * _S206);
        bool _S208 = eta_i_2 != eta_o_2;
        if(_S208)
        {
            _S203 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S203 = false;
        }
        float _S209 = _slang_select(_S203, _S207,0.0f);
        return _S209;
    }
    float _S210 = lobes_1.p_reflect * _S204 / (4.0f * lobes_1.v_dot_h);
    bool _S211 = _S204 > 0.0f;
    float _S212 = _slang_select(_S211, _S210,0.0f);
    return _S212;
}

__device__ __noinline__ float sheenBRDF(float3  l_0, float3  v_6, float3  n_5, float r_1)
{
    float _S213 = 1.0f / (F32_max((r_1), (0.05000000074505806f)));
    float3  _S214 = l_0 + v_6;
    float3  _S215 = ((((_S214)) * make_float3(rnorm3df(((_S214)).x, ((_S214)).y, ((_S214)).z))));
    float _S216 = dot_0(n_5, _S215);
    float _S217 = (F32_max((dot_0(n_5, l_0)), (0.0f)));
    float _S218 = (F32_max((dot_0(n_5, v_6)), (0.0f)));
    return (2.0f + _S213) * (F32_pow(((F32_max((1.0f - _S216 * _S216), (0.0f)))), (0.5f * _S213))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S217 + _S218 - _S217 * _S218)), (0.0000152587890625f)));
}

__device__ float3  lobeThroughput(float3  l_1, float3  n_i_2, float alpha_6, BSDFMaterial material_3, BSDFLobes lobes_2, uint lobe_1)
{
    bool _S219 = lobe_1 == 0U;
    if(_S219)
    {
        bool _S220 = (dot_0(n_i_2, l_1)) < 0.0f;
        float3  _S221 = _slang_select(_S220, material_3.translucent,material_3.albedo);
        float _S222 = 1.0f - lobes_2.translucent_share;
        float _S223 = _slang_select(_S220, lobes_2.translucent_share,_S222);
        float3  _S224 = _S221 / make_float3 (_S223);
        bool _S225 = (lobes_2.translucent_share) > 0.0f;
        float3  _S226 = _slang_select(_S225, _S224,material_3.albedo);
        float _S227 = rgb_to_greyscale(material_3.sheen);
        bool _S228 = _S227 > 0.0f;
        bool _S229;
        if(_S228)
        {
            _S229 = !_S220;
        }
        else
        {
            _S229 = false;
        }
        if(_S229)
        {
            float3  _S230 = lobes_2.diffuse_weight * _S226;
            float3  _S231 = lobes_2.sheen * make_float3 (3.14159274101257324f);
            float _S232 = sheenBRDF(l_1, lobes_2.view, n_i_2, material_3.sheen_roughness);
            float3  _S233 = _S231 * make_float3 (_S232);
            float _S234 = _slang_select(_S225, _S222,1.0f);
            return (_S230 + _S233 / make_float3 (_S234)) / make_float3 (lobes_2.p_diffuse);
        }
        return lobes_2.diffuse_weight * _S226 / make_float3 (lobes_2.p_diffuse);
    }
    bool _S235 = lobe_1 == 1U;
    if(_S235)
    {
        float _S236 = - dot_0(n_i_2, l_1);
        float _S237 = G1(alpha_6, (F32_max((_S236), (0.0f))));
        return lobes_2.refract_weight * make_float3 (_S237) * material_3.albedo / make_float3 (lobes_2.p_refract);
    }
    float _S238 = dot_0(n_i_2, l_1);
    float _S239 = G1(alpha_6, (F32_max((_S238), (0.0f))));
    return make_float3 (lobes_2.reflect_weight * _S239) * lobes_2.F / make_float3 (lobes_2.p_reflect);
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

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_0, float3  throughput_0, uint random_state_1, bool refracted_1, uint lobe_2, float pdf_0)
{
    SampleBSDF _S240;
    (&_S240)->unit_direction = unit_direction_0;
    (&_S240)->throughput = throughput_0;
    (&_S240)->random_state = random_state_1;
    (&_S240)->refracted = refracted_1;
    (&_S240)->lobe = lobe_2;
    (&_S240)->pdf = pdf_0;
    return _S240;
}

__device__ __forceinline__ SampleBSDF connectBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_6, BSDFMaterial material_4, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0)
{
    uint random_state_2 = random_init_0;
    float3  _S241 = negate_0(in_dir_1);
    float _S242 = dot_0(n_6, _S241);
    float _S243 = sign_0(_S242);
    float3  _S244 = n_6 * make_float3 (_S243);
    float _S245 = material_4.roughness;
    float _S246 = _S245 * _S245;
    float3  _S247 = _S241 + out_dir_0;
    float3  _S248 = ((((_S247)) * make_float3(rnorm3df(((_S247)).x, ((_S247)).y, ((_S247)).z))));
    bool _S249 = lobe_3 == 0U;
    float3  ggx_n_1;
    if(_S249)
    {
        float3  _S250 = sampleHalfVector(_S241, _S244, _S246, &random_state_2);
        ggx_n_1 = _S250;
    }
    else
    {
        bool _S251 = lobe_3 == 1U;
        if(_S251)
        {
            float3  _S252 = negate_0(make_float3 (eta_i_3) * _S241 + make_float3 (eta_o_3) * out_dir_0);
            float3  _S253 = ((((_S252)) * make_float3(rnorm3df(((_S252)).x, ((_S252)).y, ((_S252)).z))));
            float _S254 = sign_0(dot_0(_S252, _S244));
            float3  _S255 = _S253 * make_float3 (_S254);
            ggx_n_1 = _S255;
        }
        else
        {
            ggx_n_1 = _S248;
        }
    }
    BSDFLobes _S256 = bsdfLobes(in_dir_1, _S241, _S244, ggx_n_1, material_4, eta_i_3, eta_o_3);
    BSDFLobes lobes_3 = _S256;
    float _S257 = translucentShare(material_4);
    (&lobes_3)->translucent_share = _S257;
    float _S258 = (F32_abs((_S242)));
    BSDFLobes _S259 = sheenLobes(lobes_3, _S241, _S258, material_4);
    lobes_3 = _S259;
    float _S260 = lobeDensity(dot_0(_S244, out_dir_0), dot_0(out_dir_0, ggx_n_1), _S258, _S246, lobes_3, eta_i_3, eta_o_3, lobe_3);
    bool _S261 = !(_S260 > 0.0f);
    if(_S261)
    {
        float3  _S262 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S262, _S262, 0U, false, 0U, 0.0f);
    }
    float3  _S263 = lobeThroughput(out_dir_0, _S244, _S246, material_4, lobes_3, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S263, random_state_2, lobe_3 == 1U, lobe_3, _S260);
}

__device__ float3  BSDF(float3  in_dir_2, float3  out_dir_1, float3  n_7, float3  g_n_0, BSDFMaterial material_5, float eta_i_4, float eta_o_4, uint random_state_3)
{
    float3  _S264 = negate_0(in_dir_2);
    bool _S265 = (dot_0(g_n_0, _S264) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S265)
    {
        SampleBSDF _S266 = connectBSDF(in_dir_2, out_dir_1, n_7, material_5, eta_i_4, eta_o_4, 0U, random_state_3);
        SampleBSDF _S267 = connectBSDF(in_dir_2, out_dir_1, n_7, material_5, eta_i_4, eta_o_4, 2U, random_state_3);
        return _S266.throughput * make_float3 (_S266.pdf) + _S267.throughput * make_float3 (_S267.pdf);
    }
    SampleBSDF _S268 = connectBSDF(in_dir_2, out_dir_1, n_7, material_5, eta_i_4, eta_o_4, 1U, random_state_3);
    return _S268.throughput * make_float3 (_S268.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_3, float3  out_dir_2, float3  n_8, float3  g_n_1, BSDFMaterial material_6, float eta_i_5, float eta_o_5, uint random_state_4)
{
    float _S269 = dot_0(n_8, out_dir_2);
    float3  _S270 = negate_0(in_dir_3);
    bool _S271 = (_S269 * dot_0(n_8, _S270)) < 0.0f;
    SampleBSDF _S272 = connectBSDF(in_dir_3, out_dir_2, n_8, material_6, eta_i_5, eta_o_5, 0U, random_state_4);
    float3  _S273 = negate_0(in_dir_3);
    bool _S274 = (dot_0(g_n_1, _S273) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S275 = make_float3 (0.0f);
    float3  _S276 = _S272.throughput * make_float3 (_S272.pdf);
    float _S277 = _slang_select(_S274, -1.0f,1.0f);
    float3  _S278 = _S276 * make_float3 (_S277);
    float3  _S279 = _slang_select(_S271, _S278,_S275);
    return _S279;
}

__device__ float3  translucentBSDF(float3  in_dir_4, float3  out_dir_3, float3  n_9, float3  g_n_2, BSDFMaterial material_7, float eta_i_6, float eta_o_6, uint random_state_5)
{
    float3  _S280 = BSDF(in_dir_4, out_dir_3, n_9, g_n_2, material_7, eta_i_6, eta_o_6, random_state_5);
    float3  _S281 = translucentCorrection(in_dir_4, out_dir_3, n_9, g_n_2, material_7, eta_i_6, eta_o_6, random_state_5);
    return _S280 + _S281;
}

__device__ SampleBSDF sampleBSDF(float3  in_dir_5, float3  n_10, BSDFMaterial material_8, float eta_i_7, float eta_o_7, uint random_init_1, float2  screen_space_0)
{
    uint random_state_6 = random_init_1;
    float3  _S282 = negate_0(in_dir_5);
    float _S283 = dot_0(n_10, _S282);
    float _S284 = sign_0(_S283);
    float3  n_i_3 = n_10 * make_float3 (_S284);
    float _S285 = (F32_abs((_S283)));
    float _S286 = material_8.roughness;
    float _S287 = _S286 * _S286;
    float3  _S288 = sampleHalfVector(_S282, n_i_3, _S287, &random_state_6);
    BSDFLobes _S289 = bsdfLobes(in_dir_5, _S282, n_i_3, _S288, material_8, eta_i_7, eta_o_7);
    BSDFLobes lobes_4 = _S289;
    float _S290 = translucentShare(material_8);
    (&lobes_4)->translucent_share = _S290;
    BSDFLobes _S291 = sheenLobes(lobes_4, _S282, _S285, material_8);
    lobes_4 = _S291;
    float3  _S292 = make_float3 (1.0f);
    SampleBSDF _S293 = SampleBSDF_x24init_0(_S292, _S292, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S293;
    Random _S294 = pcg(random_state_6);
    random_state_6 = _S294.state;
    bool _S295 = (_S294.value) < ((&lobes_4)->p_diffuse);
    if(_S295)
    {
        Random _S296 = pcg(random_state_6);
        Random _S297 = pcg(_S296.state);
        (&sample_0)->random_state = _S297.state;
        float3  _S298 = sampleCosWeightedHemisphere(_S296.value, _S297.value);
        bool _S299 = (_S294.value) < ((&lobes_4)->p_diffuse * (&lobes_4)->translucent_share);
        float _S300 = _S298.y;
        float _S301 = - _S300;
        float _S302 = _slang_select(_S299, _S301,_S300);
        float3  _S303 = tangentToWorld(make_float3 (_S298.x, _S302, _S298.z), n_i_3);
        (&sample_0)->unit_direction = _S303;
        float3  _S304 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S287, material_8, lobes_4, 0U);
        (&sample_0)->throughput = _S304;
        float _S305 = lobeDensity(_S302, 0.0f, _S285, _S287, lobes_4, eta_i_7, eta_o_7, 0U);
        (&sample_0)->pdf = _S305;
        (&sample_0)->refracted = _S299;
        return sample_0;
    }
    bool _S306 = (_S294.value) < ((&lobes_4)->p_diffuse + (&lobes_4)->p_refract);
    if(_S306)
    {
        (&sample_0)->unit_direction = (&lobes_4)->refracted;
        float _S307 = lobeDensity(0.0f, dot_0((&sample_0)->unit_direction, _S288), _S285, _S287, lobes_4, eta_i_7, eta_o_7, 1U);
        (&sample_0)->pdf = _S307;
        float3  _S308 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S287, material_8, lobes_4, 1U);
        (&sample_0)->throughput = _S308;
        (&sample_0)->random_state = random_state_6;
        (&sample_0)->refracted = true;
        (&sample_0)->lobe = 1U;
        return sample_0;
    }
    float3  _S309 = reflect_0(in_dir_5, _S288);
    float3  _S310 = ((((_S309)) * make_float3(rnorm3df(((_S309)).x, ((_S309)).y, ((_S309)).z))));
    (&sample_0)->unit_direction = _S310;
    float3  _S311 = lobeThroughput((&sample_0)->unit_direction, n_i_3, _S287, material_8, lobes_4, 2U);
    (&sample_0)->throughput = _S311;
    (&sample_0)->random_state = random_state_6;
    (&sample_0)->lobe = 2U;
    float _S312 = lobeDensity(0.0f, 0.0f, _S285, _S287, lobes_4, eta_i_7, eta_o_7, 2U);
    (&sample_0)->pdf = _S312;
    return sample_0;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S313 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S313));
}

__device__ bool samplesLights(BSDFMaterial material_9)
{
    bool _S314 = (material_9.roughness) > 0.0f;
    bool _S315;
    if(_S314)
    {
        _S315 = true;
    }
    else
    {
        bool _S316 = (material_9.metallic) < 1.0f;
        if(_S316)
        {
            _S315 = (material_9.transmission) < 1.0f;
        }
        else
        {
            _S315 = false;
        }
    }
    return _S315;
}

__device__ float3  neeBSDF(float3  in_dir_6, float3  dir_0, float3  n_11, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, float pdf_1, bool power_0, uint random_state_7)
{
    float3  _S317 = make_float3 (0.0f);
    uint lobe_4 = 0U;
    float3  f_0 = _S317;
    for(;;)
    {
        if(lobe_4 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S318 = lobe_4 == 0U;
        bool _S319;
        if(_S318)
        {
            float _S320 = rgb_to_greyscale(material_10.translucent);
            _S319 = _S320 > 0.0f;
        }
        else
        {
            _S319 = false;
        }
        bool _S321;
        if(_S319)
        {
            float _S322 = dot_0(n_11, dir_0);
            float3  _S323 = negate_0(in_dir_6);
            _S321 = ((_S322 * dot_0(n_11, _S323)) < 0.0f) == refracted_2;
        }
        else
        {
            _S321 = (lobe_4 == 1U) == refracted_2;
        }
        float3  f_1;
        if(_S321)
        {
            SampleBSDF _S324 = connectBSDF(in_dir_6, dir_0, n_11, material_10, eta_i_8, eta_o_8, lobe_4, random_state_7);
            bool _S325 = (_S324.pdf) > 0.0f;
            if(_S325)
            {
                if(power_0)
                {
                    float _S326 = _S324.pdf / pdf_1;
                    float3  f_2 = f_0 + _S324.throughput * make_float3 (_S324.pdf) / make_float3 (pdf_1 * (1.0f + _S326 * _S326));
                    f_1 = f_2;
                }
                else
                {
                    float3  f_3 = f_0 + _S324.throughput * make_float3 (_S324.pdf) / make_float3 (_S324.pdf + pdf_1);
                    f_1 = f_3;
                }
            }
            else
            {
                f_1 = f_0;
            }
        }
        else
        {
            f_1 = f_0;
        }
        uint lobe_5 = lobe_4 + 1U;
        lobe_4 = lobe_5;
        f_0 = f_1;
    }
    return f_0;
}

__device__ float3  straightThrough(float3  dir_1, float3  n_12, BSDFMaterial material_11)
{
    float _S327 = material_11.transmission * (1.0f - material_11.metallic);
    float _S328 = material_11.roughness;
    float _S329 = G1(_S328 * _S328, (F32_abs((dot_0(n_12, dir_1)))));
    return make_float3 (_S327 * _S329) * material_11.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S330 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S330 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_13, BSDFMaterial material_12, float coverage_0)
{
    float3  _S331;
    if((material_12.ior) == 1.0f)
    {
        float3  _S332 = straightThrough(toward_0, n_13, material_12);
        _S331 = _S332;
    }
    else
    {
        _S331 = make_float3 (0.0f);
    }
    return _S331 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S333 = hash(index_0);
    uint _S334 = hash(seed_0 ^ _S333);
    return _S334;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S335 = a_4 / b_0;
    float3  _S336 = make_float3 (0.0f);
    bool3  _S337 = b_0 == _S336;
    float3  _S338 = _slang_select(_S337, _S336,_S335);
    return _S338;
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
    float _S339 = rgb_to_greyscale(weight_0);
    bool _S340 = _S339 > 0.0f;
    bool _S341;
    if(_S340)
    {
        _S341 = _S339 < 3.00000000549775576e+38f;
    }
    else
    {
        _S341 = false;
    }
    bool _S342 = !_S341;
    if(_S342)
    {
        return;
    }
    float _S343 = sel_0->w_sum + _S339;
    sel_0->w_sum = _S343;
    float3  _S344 = sel_0->color + weight_0;
    sel_0->color = _S344;
    Random _S345 = pcg(sel_0->random_state);
    sel_0->random_state = _S345.state;
    bool _S346 = (_S345.value * sel_0->w_sum) <= _S339;
    if(_S346)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_2, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_2;
    float3  _S347 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S347;
    float _S348 = r_2.jac * shifted_0.jac;
    (&candidate_1)->jac = _S348;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_2.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_3 = sel_2.r;
    float _S349 = rgb_to_greyscale((&r_3)->f);
    float _S350 = sel_2.w_sum / _S349;
    bool _S351 = _S349 > 0.0f;
    float _S352 = _slang_select(_S351, _S350,0.0f);
    (&r_3)->w = _S352;
    (&r_3)->c = c_0;
    return r_3;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S353 = (1U << count_0) - 1U;
    return (e_1 & (~(_S353 << offset_0))) | ((newbits_0 & _S353) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_4, uint end_type_0, uint end_1, float3  f_4)
{
    Reservoir candidate_2 = r_4;
    uint _S354 = insertBits_0(r_4.path, end_1, 0U, 5U);
    uint _S355 = insertBits_0(_S354, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S355;
    (&candidate_2)->f = f_4;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S356 = transmission_0 > 0.0f;
    bool _S357;
    if(_S356)
    {
        _S357 = true;
    }
    else
    {
        _S357 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S358;
    if(_S357)
    {
        _S358 = 1.0f;
    }
    else
    {
        _S358 = -1.0f;
    }
    return _S358;
}

__device__ float geometryDensity(float3  geometry_n_1, float3  direction_1, float distance_2)
{
    return (F32_abs((dot_0(geometry_n_1, direction_1)))) / (distance_2 * distance_2);
}

__device__ float footprintThreshold(float geometry_density_0)
{
    return 0.00251327408477664f / geometry_density_0;
}

__device__ bool withinFootprint(bool open_0, bool prev_rough_0, float prev_pdf_0, float geometry_density_1, float threshold_0)
{
    bool _S359;
    if(open_0)
    {
        _S359 = prev_rough_0;
    }
    else
    {
        _S359 = false;
    }
    if(_S359)
    {
        _S359 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S359 = false;
    }
    return _S359;
}

__device__ bool withinInverseFootprint(float pdf_2, bool diffuse_0, float prev_cos_0, float distance_3, float threshold_1)
{
    bool _S360 = pdf_2 > 0.0f;
    bool _S361;
    if(_S360)
    {
        if(diffuse_0)
        {
            _S361 = true;
        }
        else
        {
            _S361 = (pdf_2 * prev_cos_0 / (distance_3 * distance_3) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S361 = false;
    }
    return _S361;
}

__device__ bool roughLobe(float pdf_3, bool diffuse_1, float roughness_0)
{
    bool _S362 = pdf_3 > 0.0f;
    bool _S363;
    if(_S362)
    {
        if(diffuse_1)
        {
            _S363 = true;
        }
        else
        {
            _S363 = roughness_0 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S363 = false;
    }
    return _S363;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

static __device__ float interpolate_0(float a_5, float b_1, float t_3)
{
    return a_5 + (b_1 - a_5) * t_3;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S364 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S364;
}

__device__ float2  temporalWeights(float c_1, float p_c_0, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S365 = c_1 * p_c_0;
    float _S366 = c_t_0 * p_t_0;
    return make_float2 (_S365 / (_S365 + c_t_0 * g_previous_0), _S366 / (_S366 + c_1 * g_current_0));
}

__device__ float pairShare(float c_n_0, float c_pair_0, float c_sum_0)
{
    return (c_n_0 + c_pair_0) / c_sum_0;
}

__device__ float neighborWeight(float share_0, float c_n_1, float p_n_0, float c_pair_1, float g_here_0)
{
    return share_0 * c_n_1 * p_n_0 / (c_n_1 * p_n_0 + c_pair_1 * g_here_0);
}

__device__ float canonicalWeight(float share_1, float c_pair_2, float p_c_1, float c_n_2, float g_there_0)
{
    return share_1 * c_pair_2 * p_c_1 / (c_pair_2 * p_c_1 + c_n_2 * g_there_0);
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S367 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S368 = cos_a_0 > cos_b_0;
    float _S369 = _slang_select(_S368, 1.0f,_S367);
    return _S369;
}

__device__ float sinSubClamped(float sin_a_1, float cos_a_1, float sin_b_1, float cos_b_1)
{
    float _S370 = sin_a_1 * cos_b_1 - cos_a_1 * sin_b_1;
    bool _S371 = cos_a_1 > cos_b_1;
    float _S372 = _slang_select(_S371, 0.0f,_S370);
    return _S372;
}

__device__ float sine(float c_2)
{
    return (F32_sqrt(((F32_max((1.0f - c_2 * c_2), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_1)
{
    float3  _S373 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S374 = node_0.high - node_0.low;
    float3  _S375 = p_0 - _S373;
    float3  _S376 = ((((_S375)) * make_float3(rnorm3df(((_S375)).x, ((_S375)).y, ((_S375)).z))));
    float _S377 = dot_0(_S375, _S375);
    float _S378 = dot_0(_S374, _S374) / 4.0f;
    float _S379 = (F32_abs((dot_0(node_0.w, _S376))));
    float _S380 = sine(node_0.cos_theta_o);
    float _S381 = (F32_sqrt(((F32_max((1.0f - _S378 / _S377), (0.0f))))));
    bool _S382 = _S377 < _S378;
    float _S383 = _slang_select(_S382, -1.0f,_S381);
    float _S384 = sine(_S383);
    float _S385 = sine(_S379);
    float _S386 = cosSubClamped(_S385, _S379, _S380, node_0.cos_theta_o);
    float _S387 = sine(_S379);
    float _S388 = sinSubClamped(_S387, _S379, _S380, node_0.cos_theta_o);
    float _S389 = cosSubClamped(_S388, _S386, _S384, _S383);
    bool _S390 = _S389 <= 0.0f;
    if(_S390)
    {
        return 0.0f;
    }
    float _S391 = - dot_0(_S376, normal_1);
    float _S392 = node_0.phi * _S389 / (F32_max((_S377), (length_0(_S374) / 2.0f)));
    float _S393 = sine(_S391);
    float _S394 = cosSubClamped(_S393, _S391, _S384, _S383);
    bool _S395 = (dot_0(normal_1, normal_1)) == 0.0f;
    float _S396 = _slang_select(_S395, 1.0f,_S394);
    return (F32_max((_S392 * _S396), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_3, float * pick_0, float * probability_1)
{
    float _S397 = importance(first_0, p_1, normal_3);
    float _S398 = importance(second_0, p_1, normal_3);
    float2  _S399 = make_float2 (_S397, _S398);
    bool _S400 = _S397 == 0.0f;
    bool _S401;
    if(_S400)
    {
        _S401 = _S398 == 0.0f;
    }
    else
    {
        _S401 = false;
    }
    if(_S401)
    {
        return 2U;
    }
    float _S402 = _S397 + _S398;
    bool _S403 = _S398 > 0.0f;
    if(_S403)
    {
        _S401 = (*pick_0 * _S402) >= _S397;
    }
    else
    {
        _S401 = false;
    }
    uint _S404 = uint(_S401);
    float _S405 = (F32_min(((*pick_0 * _S402 - float(_S404) * _S397) / _slang_vector_get_element(_S399, _S404)), (0.99999994039535522f)));
    *pick_0 = _S405;
    float _S406 = *probability_1 * (_slang_vector_get_element(_S399, _S404) / _S402);
    *probability_1 = _S406;
    return _S404;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_4, uint child_0)
{
    float _S407 = importance(first_1, p_2, normal_4);
    float _S408 = importance(second_1, p_2, normal_4);
    float2  _S409 = make_float2 (_S407, _S408);
    float _S410 = _slang_vector_get_element(_S409, child_0) / (_S407 + _S408);
    bool _S411 = _slang_vector_get_element(_S409, child_0) > 0.0f;
    float _S412 = _slang_select(_S411, _S410,0.0f);
    return _S412;
}

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S413 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S414 = b_2 > 0.0f;
    float _S415 = _slang_select(_S414, _S413,1.0f);
    return _S415;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S416 = center_0 - p_3;
    float _S417 = radius_1 * radius_1 / dot_0(_S416, _S416);
    bool _S418 = _S417 >= 1.0f;
    if(_S418)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S417)))) / (6.28318548202514648f * _S417);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S419 = center_1 - p_4;
    float _S420 = radius_2 * radius_2 / dot_0(_S419, _S419);
    float _S421 = u1_0 * _S420 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S420), (0.0f)))))));
    float _S422 = 2.0f * u1_0;
    bool _S423 = _S420 >= 1.0f;
    float _S424 = _slang_select(_S423, _S422,_S421);
    float _S425 = (F32_sqrt(((F32_max((_S424 * (2.0f - _S424)), (0.0f))))));
    float _S426 = 6.28318548202514648f * u2_0;
    float3  _S427 = make_float3 (_S425 * (F32_cos((_S426))), 1.0f - _S424, _S425 * (F32_sin((_S426))));
    float3  _S428 = ((((_S419)) * make_float3(rnorm3df(((_S419)).x, ((_S419)).y, ((_S419)).z))));
    float3  _S429 = tangentToWorld(_S427, _S428);
    return _S429;
}

#undef Matrix
