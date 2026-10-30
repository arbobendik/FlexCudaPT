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
    float3  _S47 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S48 = make_float3 (- _S45, _S44, 0.0f);
    float _S49 = (rsqrtf((_S46)));
    float3  _S50 = _S48 * make_float3 (_S49);
    bool _S51 = _S46 > 0.0f;
    float3  _S52 = _slang_select(_S51, _S50,_S47);
    float3  _S53 = cross_0(_S43, _S52);
    float _S54 = (F32_sqrt((U1_0)));
    float _S55 = 6.28318548202514648f * U2_0;
    float _S56 = _S54 * (F32_cos((_S55)));
    float t2_0 = _S54 * (F32_sin((_S55)));
    float _S57 = 0.5f * (1.0f + _S43.z);
    float t2_1 = (1.0f - _S57) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S56 * _S56)))))) + _S57 * t2_0;
    float3  _S58 = make_float3 (_S56) * _S52 + make_float3 (t2_1) * _S53;
    float _S59 = unshared_0(_S56);
    float _S60 = unshared_0(_S56);
    float3  _S61 = _S58 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S59 * _S60 - t2_1 * t2_1))))))) * _S43;
    float3  _S62 = make_float3 (alpha_2 * _S61.x, alpha_2 * _S61.y, (F32_max((0.0f), (_S61.z))));
    float3  _S63 = ((((_S62)) * make_float3(rnorm3df(((_S62)).x, ((_S62)).y, ((_S62)).z))));
    return _S63;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S64 = (F32_sqrt((random_1_0)));
    float _S65 = 6.28318548202514648f * random_2_0;
    float _S66 = _S64 * (F32_cos((_S65)));
    float _S67 = _S64 * (F32_sin((_S65)));
    float _S68 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S66 * _S66 - _S67 * _S67))))));
    return make_float3 (_S66, _S68, _S67);
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_2)
{
    float3  a_0 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S69 = (F32_abs((dot_0(n_2, a_0)))) > 0.9999847412109375f;
    float3  a_1;
    if(_S69)
    {
        float3  _S70 = make_float3 (1.0f, 0.0f, 0.0f);
        a_1 = _S70;
    }
    else
    {
        a_1 = a_0;
    }
    float3  _S71 = cross_0(n_2, a_1);
    float3  _S72 = ((((_S71)) * make_float3(rnorm3df(((_S71)).x, ((_S71)).y, ((_S71)).z))));
    float3  _S73 = cross_0(n_2, _S72);
    return make_float3 (v_0.x) * _S72 + make_float3 (v_0.y) * n_2 + make_float3 (v_0.z) * _S73;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
{
    float3  a_2 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S74 = (F32_abs((dot_0(n_3, a_2)))) > 0.9999847412109375f;
    float3  a_3;
    if(_S74)
    {
        float3  _S75 = make_float3 (1.0f, 0.0f, 0.0f);
        a_3 = _S75;
    }
    else
    {
        a_3 = a_2;
    }
    float3  _S76 = cross_0(n_3, a_3);
    float3  _S77 = ((((_S76)) * make_float3(rnorm3df(((_S76)).x, ((_S76)).y, ((_S76)).z))));
    float3  _S78 = cross_0(n_3, _S77);
    return make_float3 (dot_0(v_1, _S77), dot_0(v_1, n_3), dot_0(v_1, _S78));
}

static __device__ float3  negate_0(float3  x_14)
{
    return - x_14;
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_4)
{
    float3  _S79 = p1_0 - p0_0;
    float3  _S80 = p2_0 - p0_0;
    float2  _S81 = uv1_0 - uv0_0;
    float2  _S82 = uv2_0 - uv0_0;
    float _S83 = _S81.x;
    float _S84 = _S82.y;
    float _S85 = _S81.y;
    float _S86 = _S82.x;
    float _S87 = _S83 * _S84 - _S85 * _S86;
    float _S88 = 1.0f / _S87;
    float3  t_0 = (_S79 * make_float3 (_S84) - _S80 * make_float3 (_S85)) * make_float3 (_S88);
    float3  _S89 = (_S80 * make_float3 (_S83) - _S79 * make_float3 (_S86)) * make_float3 (_S88);
    float3  _S90 = t_0 - n_4 * make_float3 (dot_0(n_4, t_0));
    float3  _S91 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_4);
    bool _S92 = (dot_0(_S90, _S90)) > 0.0f;
    float3  _S93 = _slang_select(_S92, _S90,_S91);
    float3  _S94 = ((((_S93)) * make_float3(rnorm3df(((_S93)).x, ((_S93)).y, ((_S93)).z))));
    bool _S95 = (dot_0(cross_0(n_4, _S94), _S89)) > 0.0f;
    float3  t_1;
    if(_S95)
    {
        float3  _S96 = negate_0(_S94);
        t_1 = _S96;
    }
    else
    {
        t_1 = _S94;
    }
    float3  _S97 = cross_0(n_4, t_1);
    return makeMatrix<float, 3, 3> (t_1, _S97, n_4);
}

__device__ float3  tangentToWorldNormalMap(float3  v_2, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_2, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_0, float3  uvw_0, float3  position_0)
{
    float3  _S98 = t1_0 - t0_0;
    float3  _S99 = t2_2 - t0_0;
    float3  _S100 = t2_2 - t1_0;
    float _S101 = (F32_min((length_0(_S98)), ((F32_min((length_0(_S99)), (length_0(_S100)))))));
    float3  _S102 = make_float3 (distance_0(position_0, t0_0), distance_0(position_0, t1_0), distance_0(position_0, t2_2));
    float3  _S103 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S104 = dot_0(geometry_n_0, _S103);
    float3  _S105 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S106 = dot_0(geometry_n_0, _S105);
    float3  _S107 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S108 = acos_0(abs_0(make_float3 (_S104, _S106, dot_0(geometry_n_0, _S107))));
    float3  _S109 = clamp_0(tan_0(_S108), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S102 * _S109, uvw_0), 0.0f, _S101 * 0.125f);
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S110;
    (&_S110)->on = on_0;
    (&_S110)->albedo = albedo_0;
    return _S110;
}

__device__ __forceinline__ SheenProfile sheenProfile(float3  v_3, float3  n_i_0, BSDFMaterial material_0)
{
    SheenProfile _S111 = SheenProfile_x24init_0(false, 0.0f);
    float _S112 = rgb_to_greyscale(material_0.sheen);
    bool _S113 = _S112 > 0.0f;
    SheenProfile profile_0;
    if(_S113)
    {
        float _S114 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_0, v_3)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S115 = (U32_min((uint(_S114)), (22U)));
        float _S116 = (F32_sqrt((0.05000000074505806f)));
        float _S117 = (clamp_1((F32_sqrt(((F32_max((material_0.sheen_roughness), (0.0f)))))), _S116, 1.0f) - _S116) / (1.0f - _S116) * 23.0f;
        uint _S118 = (U32_min((uint(_S117)), (22U)));
        uint _S119 = _S115 * 24U + _S118;
        float _S120 = _S114 - float(_S115);
        float _S121 = _S117 - float(_S118);
        uint _S122 = _S119 + 24U;
        float _S123 = SHEEN_ALBEDO_0[_S119] + (SHEEN_ALBEDO_0[_S122] - SHEEN_ALBEDO_0[_S119]) * _S120;
        uint _S124 = _S119 + 1U;
        float _S125 = SHEEN_ALBEDO_0[_S124] + (SHEEN_ALBEDO_0[_S122 + 1U] - SHEEN_ALBEDO_0[_S124]) * _S120;
        SheenProfile _S126 = SheenProfile_x24init_0(true, (F32_exp((_S123 + (_S125 - _S123) * _S121))));
        profile_0 = _S126;
    }
    else
    {
        profile_0 = _S111;
    }
    return profile_0;
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_4, float3  n_i_1, float alpha_3, uint * random_state_0)
{
    Random _S127 = pcg(*random_state_0);
    Random _S128 = pcg(_S127.state);
    *random_state_0 = _S128.state;
    float3  _S129 = worldToTangent(v_4, n_i_1);
    float3  _S130 = sampleGGXVNDF(float3 {_S129.x, _S129.z, _S129.y}, alpha_3, _S127.value, _S128.value);
    float3  _S131 = float3 {_S130.x, _S130.z, _S130.y};
    float3  _S132 = tangentToWorld(_S131, n_i_1);
    return _S132;
}

static __device__ float sign_0(float e_0)
{
    bool _S133 = e_0 < 0.0f;
    float _S134 = _slang_select(_S133, -1.0f,0.0f);
    bool _S135 = e_0 > 0.0f;
    float _S136 = _slang_select(_S135, 1.0f,_S134);
    return _S136;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_5, BSDFMaterial material_1, uint random_state_1)
{
    uint state_5 = random_state_1;
    float3  _S137 = negate_0(in_dir_0);
    float _S138 = sign_0(dot_0(n_5, _S137));
    float _S139 = material_1.roughness;
    float3  _S140 = sampleHalfVector(_S137, n_5 * make_float3 (_S138), _S139 * _S139, &state_5);
    return _S140;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S141 = negate_0(in_dir_1);
    float3  _S142 = negate_0(make_float3 (eta_i_1) * _S141 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S143 = ((((_S142)) * make_float3(rnorm3df(((_S142)).x, ((_S142)).y, ((_S142)).z))));
    float _S144 = sign_0(dot_0(n_6, _S141));
    float _S145 = sign_0(dot_0(_S142, n_6 * make_float3 (_S144)));
    return _S143 * make_float3 (_S145);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S146 = negate_0(in_dir_2);
    float3  _S147 = _S146 + out_dir_1;
    float3  _S148 = ((((_S147)) * make_float3(rnorm3df(((_S147)).x, ((_S147)).y, ((_S147)).z))));
    return _S148;
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
};

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_1, float3  refracted_0, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0)
{
    BSDFLobes _S149;
    (&_S149)->v_dot_h = v_dot_h_0;
    (&_S149)->n_dot_h = n_dot_h_1;
    (&_S149)->refracted = refracted_0;
    (&_S149)->F = F_0;
    (&_S149)->F_greyscale = F_greyscale_0;
    (&_S149)->reflect_weight = reflect_weight_0;
    (&_S149)->diffuse_weight = diffuse_weight_0;
    (&_S149)->refract_weight = refract_weight_0;
    (&_S149)->p_diffuse = p_diffuse_0;
    (&_S149)->p_reflect = p_reflect_0;
    (&_S149)->p_refract = p_refract_0;
    (&_S149)->translucent_share = translucent_share_0;
    (&_S149)->sheen = sheen_0;
    (&_S149)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S149)->view = view_0;
    return _S149;
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_5, float3  n_i_2, float3  ggx_n_0, BSDFMaterial material_2, float eta_i_2, float eta_o_2, SheenProfile sheen_profile_0)
{
    float _S150 = dot_0(ggx_n_0, v_5);
    float _S151 = dot_0(n_i_2, ggx_n_0);
    float _S152 = eta_i_2 / eta_o_2;
    float3  _S153 = refract_0(in_dir_3, ggx_n_0, _S152);
    float3  _S154 = ((((_S153)) * make_float3(rnorm3df(((_S153)).x, ((_S153)).y, ((_S153)).z))));
    float _S155 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S156 = _S155 * _S155;
    float _S157 = (1.0f + _S155) / (1.0f - _S155);
    float _S158 = (F32_abs((_S150)));
    bool _S159 = eta_i_2 > eta_o_2;
    float _S160 = _slang_select(_S159, _S157,1.0f);
    float _S161 = _slang_select(_S159, 1.0f,_S157);
    float _S162 = fresnel(_S158, _S160, _S161);
    bool _S163 = (eta_i_2 * eta_i_2 * (1.0f - _S150 * _S150)) >= (eta_o_2 * eta_o_2);
    float3  _S164 = material_2.specular_tint * make_float3 (_S156);
    float3  _S165 = _S164 + (make_float3 (1.0f) - _S164) * make_float3 (_S162 - _S156) / make_float3 (1.0f - _S156);
    float3  _S166 = make_float3 (1.0f);
    float3  _S167 = _slang_select(_S163, _S166,_S165);
    float3  _S168 = make_float3 (0.0f);
    float3  scale_0;
    float3  sheen_1;
    float3  view_1;
    float sheen_component_0;
    if(sheen_profile_0.on)
    {
        float _S169 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S170 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S169);
        float _S171 = rgb_to_greyscale(material_2.sheen);
        float _S172 = _S171 * _S169;
        float3  _S173 = material_2.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        scale_0 = _S170;
        sheen_component_0 = _S172;
        sheen_1 = _S173;
        view_1 = v_5;
    }
    else
    {
        scale_0 = _S166;
        sheen_component_0 = 0.0f;
        sheen_1 = _S168;
        view_1 = _S168;
    }
    float3  _S174 = mix_0(_S167, material_2.albedo, material_2.metallic);
    float3  F_1 = _S174 * scale_0;
    float _S175 = rgb_to_greyscale(F_1);
    float _S176 = 1.0f - material_2.metallic;
    float3  _S177 = make_float3 (1.0f) - _S167;
    float3  _S178 = make_float3 ((1.0f - material_2.transmission) * _S176) * _S177 * scale_0;
    float3  _S179 = make_float3 (material_2.transmission * _S176) * _S177 * scale_0;
    float _S180 = (F32_max((_S175), (0.0f)));
    float _S181 = rgb_to_greyscale(_S178);
    float _S182 = (F32_max((_S181), (0.0f)));
    float _S183 = rgb_to_greyscale(_S179);
    float _S184 = sign_0(length_0(_S154));
    float _S185 = (F32_max((_S183 * _S184), (0.0f)));
    float _S186 = _S180 + _S182 + _S185;
    float _S187 = (F32_min((sheen_component_0), (1.0f)));
    bool _S188 = sheen_component_0 > 0.0f;
    bool _S189;
    if(_S188)
    {
        _S189 = !(_S186 > 0.0f);
    }
    else
    {
        _S189 = false;
    }
    float _S190 = _slang_select(_S189, 1.0f,_S187);
    float _S191 = (1.0f - _S190) / (F32_max((_S186), (0.0000152587890625f)));
    float _S192 = _S182 * _S191;
    float _S193 = _S180 * _S191;
    float _S194 = _S185 * _S191;
    return BSDFLobes_x24init_0(_S150, _S151, _S154, F_1, _S175, 1.0f, _S178, _S179, _S192, _S193, _S194, 0.0f, sheen_1, _S190, view_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S195 = rgb_to_greyscale(material_3.translucent);
    float _S196 = rgb_to_greyscale(material_3.albedo);
    float _S197 = _S195 / (_S196 + _S195);
    bool _S198 = _S195 > 0.0f;
    float _S199 = _slang_select(_S198, _S197,0.0f);
    return _S199;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S200 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S201 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S202 = 1.0f - lobes_0.translucent_share;
    bool _S203 = n_i_dot_l_0 < 0.0f;
    float _S204 = _slang_select(_S203, lobes_0.translucent_share,_S202);
    float _S205 = _S201 * _S204;
    bool _S206 = (lobes_0.translucent_share) > 0.0f;
    float _S207 = _slang_select(_S206, _S205,_S200);
    bool _S208 = n_i_dot_v_0 > 0.0f;
    float _S209 = _slang_select(_S208, _S207,0.0f);
    return _S209;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_5, BSDFMaterial material_4, BSDFLobes lobes_1)
{
    bool _S210 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S211 = _slang_select(_S210, material_4.translucent,material_4.albedo);
    float _S212 = 1.0f - lobes_1.translucent_share;
    float _S213 = _slang_select(_S210, lobes_1.translucent_share,_S212);
    float3  _S214 = _S211 / make_float3 (_S213);
    bool _S215 = (lobes_1.translucent_share) > 0.0f;
    float3  _S216 = _slang_select(_S215, _S214,material_4.albedo);
    return lobes_1.diffuse_weight * _S216 / make_float3 (lobes_1.p_diffuse);
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S217 = smithG1(alpha_6, n_i_dot_v_1);
    float _S218 = _S217 * lobes_2.v_dot_h;
    float _S219 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S220 = _S218 * _S219 / n_i_dot_v_1;
    bool _S221 = alpha_6 > 0.0f;
    bool _S222;
    if(_S221)
    {
        _S222 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S222 = false;
    }
    if(_S222)
    {
        _S222 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S222 = false;
    }
    if(_S222)
    {
        _S222 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S222 = false;
    }
    float _S223 = _slang_select(_S222, _S220,0.0f);
    return _S223;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S224 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S225 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S226 = lobes_3.p_refract * _S224 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S225 * _S225);
    bool _S227 = eta_i_4 != eta_o_4;
    bool _S228;
    if(_S227)
    {
        _S228 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S228 = false;
    }
    float _S229 = _slang_select(_S228, _S226,0.0f);
    return _S229;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_5, BSDFLobes lobes_4)
{
    float _S230 = - dot_0(n_i_4, l_1);
    float _S231 = smithG1(alpha_8, (F32_max((_S230), (0.0f))));
    return lobes_4.refract_weight * make_float3 (_S231) * material_5.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S232 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S233 = n_i_dot_l_2 > 0.0f;
    bool _S234;
    if(_S233)
    {
        _S234 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S234 = false;
    }
    float _S235 = _slang_select(_S234, _S232,0.0f);
    return _S235;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_6, BSDFLobes lobes_6)
{
    float3  _S236 = l_2 + lobes_6.view;
    float3  _S237 = ((((_S236)) * make_float3(rnorm3df(((_S236)).x, ((_S236)).y, ((_S236)).z))));
    float _S238 = dot_0(n_i_5, _S237);
    float _S239 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S240 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S241 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S242 = (2.0f + _S241) * (F32_pow(((F32_max((1.0f - _S238 * _S238), (0.0f)))), (0.5f * _S241))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S239 + _S240 - _S239 * _S240)), (0.0000152587890625f)));
    return lobes_6.sheen * make_float3 (_S242 * _S239 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S243 = vndfPDF(n_i_dot_v_4, alpha_11, lobes_7);
    float _S244 = lobes_7.p_reflect * _S243 / (4.0f * lobes_7.v_dot_h);
    bool _S245 = _S243 > 0.0f;
    float _S246 = _slang_select(_S245, _S244,0.0f);
    return _S246;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_7, BSDFLobes lobes_8)
{
    float _S247 = dot_0(n_i_6, l_3);
    float _S248 = smithG1(alpha_12, (F32_max((_S247), (0.0f))));
    return make_float3 (lobes_8.reflect_weight * _S248) * lobes_8.F / make_float3 (lobes_8.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_8, float eta_i_7, float eta_o_7, bool refracted_1, uint random_state_2, FixedArray<float3 , 4>  * throughputs_0, FixedArray<float, 4>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S249 = negate_0(in_dir_4);
    float _S250 = dot_0(n_7, _S249);
    float _S251 = sign_0(_S250);
    float3  _S252 = n_7 * make_float3 (_S251);
    float _S253 = dot_0(_S252, out_dir_2);
    float _S254 = material_8.roughness;
    float _S255 = _S254 * _S254;
    SheenProfile _S256 = sheenProfile(_S249, _S252, material_8);
    float _S257 = rgb_to_greyscale(material_8.translucent);
    bool _S258 = _S257 > 0.0f;
    bool _S259 = (dot_0(n_7, out_dir_2) * _S250) < 0.0f;
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
        float3  _S260 = make_float3 (0.0f);
        (*throughputs_0)[i_10] = _S260;
        (*pdfs_0)[i_10] = 0.0f;
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    float3  _S261 = make_float3 (0.0f);
    BSDFLobes _S262 = BSDFLobes_x24init_0(0.0f, 0.0f, _S261, _S261, 0.0f, 0.0f, _S261, _S261, 0.0f, 0.0f, 0.0f, 0.0f, _S261, 0.0f, _S261);
    BSDFLobes lobe_terms_0 = _S262;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S261;
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
        uint _S263;
        if(i_10 == 3U)
        {
            _S263 = 4U;
        }
        else
        {
            _S263 = i_10;
        }
        bool _S264 = _S263 == 0U;
        bool _S265;
        if(_S264)
        {
            _S265 = _S258;
        }
        else
        {
            _S265 = false;
        }
        bool _S266;
        if(_S265)
        {
            _S266 = _S259;
        }
        else
        {
            _S266 = _S263 == 1U;
        }
        bool _S267 = _S266 != refracted_1;
        if(_S267)
        {
            ggx_n_1 = ggx_n_2;
            uint i_12 = i_10 + 1U;
            ggx_n_2 = ggx_n_1;
            i_10 = i_12;
            continue;
        }
        uint _S268;
        if(_S263 == 4U)
        {
            _S268 = 2U;
        }
        else
        {
            _S268 = _S263;
        }
        bool _S269 = _S268 != half_of_0;
        uint half_of_1;
        if(_S269)
        {
            bool _S270 = _S268 == 0U;
            if(_S270)
            {
                float3  _S271 = sampledHalf(in_dir_4, n_7, material_8, random_state_2);
                ggx_n_1 = _S271;
            }
            else
            {
                bool _S272 = _S268 == 1U;
                if(_S272)
                {
                    float3  _S273 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_7, eta_o_7);
                    ggx_n_1 = _S273;
                }
                else
                {
                    float3  _S274 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S274;
                }
            }
            float3  _S275 = negate_0(in_dir_4);
            BSDFLobes _S276 = bsdfLobes(in_dir_4, _S275, _S252, ggx_n_1, material_8, eta_i_7, eta_o_7, _S256);
            lobe_terms_0 = _S276;
            float _S277 = translucentShare(material_8);
            (&lobe_terms_0)->translucent_share = _S277;
            half_of_1 = _S268;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S263)
        {
        case 0U:
            {
                float _S278 = diffusePDF(_S253, 0.0f, (F32_abs((_S250))), _S255, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(0)] = _S278;
                float3  _S279 = diffuseBSDF(out_dir_2, _S252, _S255, material_8, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S279;
                break;
            }
        case 1U:
            {
                float _S280 = refractPDF(_S253, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S250))), _S255, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(1)] = _S280;
                float3  _S281 = refractBSDF(out_dir_2, _S252, _S255, material_8, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S281;
                break;
            }
        case 4U:
            {
                float _S282 = sheenVelvetPDF(_S253, 0.0f, (F32_abs((_S250))), _S255, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(3)] = _S282;
                float3  _S283 = sheenVelvetBSDF(out_dir_2, _S252, _S255, material_8, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S283;
                break;
            }
        default:
            {
                float _S284 = reflectPDF(_S253, 0.0f, (F32_abs((_S250))), _S255, lobe_terms_0, eta_i_7, eta_o_7);
                (*pdfs_0)[int(2)] = _S284;
                float3  _S285 = reflectBSDF(out_dir_2, _S252, _S255, material_8, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S285;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_12 = i_10 + 1U;
        ggx_n_2 = ggx_n_1;
        i_10 = i_12;
    }
    i_10 = 0U;
    ggx_n_1 = _S261;
    for(;;)
    {
        if(i_10 < 4U)
        {
        }
        else
        {
            break;
        }
        bool _S286 = ((*pdfs_0)[i_10]) > 0.0f;
        if(_S286)
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
    SampleBSDF _S287;
    (&_S287)->unit_direction = unit_direction_0;
    (&_S287)->throughput = throughput_0;
    (&_S287)->random_state = random_state_3;
    (&_S287)->refracted = refracted_2;
    (&_S287)->lobe = lobe_0;
    (&_S287)->pdf = pdf_0;
    return _S287;
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_0, float3  n_i_7, float n_i_dot_v_5, float alpha_13, BSDFMaterial material_9, BSDFLobes lobes_9, float eta_i_8, float eta_o_8, uint random_state_4)
{
    float3  _S288 = make_float3 (1.0f);
    SampleBSDF _S289 = SampleBSDF_x24init_0(_S288, _S288, 0U, false, 0U, 0.0f);
    SampleBSDF sample_0 = _S289;
    Random _S290 = pcg(random_state_4);
    Random _S291 = pcg(_S290.state);
    (&sample_0)->random_state = _S291.state;
    float3  _S292 = sampleCosWeightedHemisphere(_S290.value, _S291.value);
    bool _S293 = u_0 < (lobes_9.p_diffuse * lobes_9.translucent_share);
    float _S294 = _S292.y;
    float _S295 = - _S294;
    float _S296 = _slang_select(_S293, _S295,_S294);
    float3  _S297 = tangentToWorld(make_float3 (_S292.x, _S296, _S292.z), n_i_7);
    (&sample_0)->unit_direction = _S297;
    (&sample_0)->refracted = _S293;
    (&sample_0)->lobe = 0U;
    float3  _S298 = diffuseBSDF((&sample_0)->unit_direction, n_i_7, alpha_13, material_9, lobes_9);
    (&sample_0)->throughput = _S298;
    float _S299 = diffusePDF(_S296, 0.0f, n_i_dot_v_5, alpha_13, lobes_9, eta_i_8, eta_o_8);
    (&sample_0)->pdf = _S299;
    return sample_0;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_14, BSDFMaterial material_10, BSDFLobes lobes_10, float eta_i_9, float eta_o_9, uint random_state_5)
{
    float3  _S300 = make_float3 (1.0f);
    SampleBSDF _S301 = SampleBSDF_x24init_0(_S300, _S300, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S301;
    Random _S302 = pcg(random_state_5);
    Random _S303 = pcg(_S302.state);
    (&sample_1)->random_state = _S303.state;
    float _S304 = _S302.value;
    float _S305 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S304 * _S304))))));
    float _S306 = 6.28318548202514648f * _S303.value;
    float3  _S307 = tangentToWorld(make_float3 (_S305 * (F32_cos((_S306))), _S302.value, _S305 * (F32_sin((_S306)))), n_i_8);
    (&sample_1)->unit_direction = _S307;
    (&sample_1)->lobe = 4U;
    float3  _S308 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_14, material_10, lobes_10);
    (&sample_1)->throughput = _S308;
    float _S309 = sheenVelvetPDF(_S302.value, 0.0f, n_i_dot_v_6, alpha_14, lobes_10, eta_i_9, eta_o_9);
    (&sample_1)->pdf = _S309;
    return sample_1;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_9, float n_i_dot_v_7, float alpha_15, BSDFMaterial material_11, BSDFLobes lobes_11, float eta_i_10, float eta_o_10, uint random_state_6)
{
    float3  _S310 = make_float3 (1.0f);
    SampleBSDF _S311 = SampleBSDF_x24init_0(_S310, _S310, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S311;
    (&sample_2)->unit_direction = lobes_11.refracted;
    (&sample_2)->random_state = random_state_6;
    (&sample_2)->refracted = true;
    (&sample_2)->lobe = 1U;
    float3  _S312 = refractBSDF((&sample_2)->unit_direction, n_i_9, alpha_15, material_11, lobes_11);
    (&sample_2)->throughput = _S312;
    float _S313 = refractPDF(0.0f, dot_0((&sample_2)->unit_direction, ggx_n_3), n_i_dot_v_7, alpha_15, lobes_11, eta_i_10, eta_o_10);
    (&sample_2)->pdf = _S313;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_5, float3  ggx_n_4, float3  n_i_10, float n_i_dot_v_8, float alpha_16, BSDFMaterial material_12, BSDFLobes lobes_12, float eta_i_11, float eta_o_11, uint random_state_7)
{
    float3  _S314 = make_float3 (1.0f);
    SampleBSDF _S315 = SampleBSDF_x24init_0(_S314, _S314, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S315;
    float3  _S316 = reflect_0(in_dir_5, ggx_n_4);
    float3  _S317 = ((((_S316)) * make_float3(rnorm3df(((_S316)).x, ((_S316)).y, ((_S316)).z))));
    (&sample_3)->unit_direction = _S317;
    (&sample_3)->random_state = random_state_7;
    (&sample_3)->lobe = 2U;
    float3  _S318 = reflectBSDF((&sample_3)->unit_direction, n_i_10, alpha_16, material_12, lobes_12);
    (&sample_3)->throughput = _S318;
    float _S319 = reflectPDF(0.0f, 0.0f, n_i_dot_v_8, alpha_16, lobes_12, eta_i_11, eta_o_11);
    (&sample_3)->pdf = _S319;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_6, float3  n_8, BSDFMaterial material_13, float eta_i_12, float eta_o_12, uint random_init_0, float2  screen_space_0)
{
    uint random_state_8 = random_init_0;
    float3  _S320 = negate_0(in_dir_6);
    float _S321 = dot_0(n_8, _S320);
    float _S322 = sign_0(_S321);
    float3  n_i_11 = n_8 * make_float3 (_S322);
    float _S323 = (F32_abs((_S321)));
    float _S324 = material_13.roughness;
    float _S325 = _S324 * _S324;
    SheenProfile _S326 = sheenProfile(_S320, n_i_11, material_13);
    float3  _S327 = sampleHalfVector(_S320, n_i_11, _S325, &random_state_8);
    BSDFLobes _S328 = bsdfLobes(in_dir_6, _S320, n_i_11, _S327, material_13, eta_i_12, eta_o_12, _S326);
    BSDFLobes lobes_13 = _S328;
    float _S329 = translucentShare(material_13);
    (&lobes_13)->translucent_share = _S329;
    Random _S330 = pcg(random_state_8);
    random_state_8 = _S330.state;
    bool _S331 = (_S330.value) < ((&lobes_13)->p_sheen_velvet);
    if(_S331)
    {
        SampleBSDF _S332 = sheenVelvetSample(n_i_11, _S323, _S325, material_13, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S332;
    }
    float _S333 = _S330.value - (&lobes_13)->p_sheen_velvet;
    bool _S334 = _S333 < ((&lobes_13)->p_diffuse);
    if(_S334)
    {
        SampleBSDF _S335 = diffuseSample(_S333, n_i_11, _S323, _S325, material_13, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S335;
    }
    bool _S336 = _S333 < ((&lobes_13)->p_diffuse + (&lobes_13)->p_refract);
    if(_S336)
    {
        SampleBSDF _S337 = refractSample(_S327, n_i_11, _S323, _S325, material_13, lobes_13, eta_i_12, eta_o_12, random_state_8);
        return _S337;
    }
    SampleBSDF _S338 = reflectSample(in_dir_6, _S327, n_i_11, _S323, _S325, material_13, lobes_13, eta_i_12, eta_o_12, random_state_8);
    return _S338;
}

__device__ float3  pointLightRadiance(float3  color_0, float intensity_0, float radius_0)
{
    return color_0 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_0 * radius_0);
}

__device__ float3  beerLambert(float distance_1, float3  absorption_0)
{
    float3  _S339 = max_0(absorption_0, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_1) * log_0(_S339));
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_0, float eta_i_13, float eta_o_13)
{
    float _S340 = fresnel((F32_abs((n_dot_v_0))), eta_i_13, eta_o_13);
    float3  _S341 = mix_0(make_float3 (_S340), material_14.albedo, material_14.metallic);
    float _S342 = rgb_to_greyscale(_S341);
    float _S343 = (F32_max(((1.0f - _S342) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S344 = _S343 > 0.03999999910593033f;
    bool _S345;
    if(_S344)
    {
        _S345 = true;
    }
    else
    {
        _S345 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S345;
}

__device__ float3  straightThrough(BSDFMaterial material_15)
{
    return make_float3 (material_15.transmission * (1.0f - material_15.metallic)) * material_15.albedo;
}

__device__ float3  shadowLift(float3  light_n_0, float light_offset_0, float3  start_0, float3  end_0)
{
    float _S346 = sign_0(dot_0(light_n_0, start_0 - end_0));
    return light_n_0 * make_float3 (_S346 * light_offset_0);
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

__device__ float3  occluderTransmittance(float3  toward_0, float3  n_9, BSDFMaterial material_16, float coverage_0)
{
    float3  _S347;
    if((material_16.ior) == 1.0f)
    {
        float3  _S348 = straightThrough(material_16);
        _S347 = _S348;
    }
    else
    {
        _S347 = make_float3 (0.0f);
    }
    return _S347 * make_float3 (coverage_0) + make_float3 (1.0f - coverage_0);
}

__device__ uint stream(uint seed_0, uint index_0)
{
    uint _S349 = hash(index_0);
    uint _S350 = hash(seed_0 ^ _S349);
    return _S350;
}

__device__ float3  safeDivide(float3  a_4, float3  b_0)
{
    float3  _S351 = a_4 / b_0;
    float3  _S352 = make_float3 (0.0f);
    bool3  _S353 = b_0 == _S352;
    float3  _S354 = _slang_select(_S353, _S352,_S351);
    return _S354;
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
    float _S355 = rgb_to_greyscale(weight_0);
    bool _S356 = _S355 > 0.0f;
    bool _S357;
    if(_S356)
    {
        _S357 = _S355 < 3.00000000549775576e+38f;
    }
    else
    {
        _S357 = false;
    }
    bool _S358 = !_S357;
    if(_S358)
    {
        return;
    }
    float _S359 = sel_0->w_sum + _S355;
    sel_0->w_sum = _S359;
    float3  _S360 = sel_0->color + weight_0;
    sel_0->color = _S360;
    Random _S361 = pcg(sel_0->random_state);
    sel_0->random_state = _S361.state;
    bool _S362 = (_S361.value * sel_0->w_sum) <= _S355;
    if(_S362)
    {
        sel_0->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_1, Reservoir r_0, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_0;
    float3  _S363 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S363;
    float _S364 = r_0.jac * shifted_0.jac;
    (&candidate_1)->jac = _S364;
    offer(sel_1, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_0.w));
    return;
}

__device__ Reservoir finalize(Selection sel_2, float c_0)
{
    Reservoir r_1 = sel_2.r;
    float _S365 = rgb_to_greyscale((&r_1)->f);
    float _S366 = sel_2.w_sum / _S365;
    bool _S367 = _S365 > 0.0f;
    float _S368 = _slang_select(_S367, _S366,0.0f);
    (&r_1)->w = _S368;
    (&r_1)->c = c_0;
    return r_1;
}

static __device__ uint insertBits_0(uint e_1, uint newbits_0, uint offset_0, uint count_0)
{
    uint _S369 = (1U << count_0) - 1U;
    return (e_1 & (~(_S369 << offset_0))) | ((newbits_0 & _S369) << offset_0);
}

__device__ Reservoir withEnd(Reservoir r_2, uint end_type_0, uint end_1, float3  f_1)
{
    Reservoir candidate_2 = r_2;
    uint _S370 = insertBits_0(r_2.path, end_1, 0U, 5U);
    uint _S371 = insertBits_0(_S370, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S371;
    (&candidate_2)->f = f_1;
    return candidate_2;
}

__device__ float facingSign(float transmission_0, float3  face_0, float3  direction_0)
{
    bool _S372 = transmission_0 > 0.0f;
    bool _S373;
    if(_S372)
    {
        _S373 = true;
    }
    else
    {
        _S373 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S374;
    if(_S373)
    {
        _S374 = 1.0f;
    }
    else
    {
        _S374 = -1.0f;
    }
    return _S374;
}

__device__ float survivalProbability(float3  throughput_1, float density_0)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_0), (0.0f)))), (1.0f)));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S375 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S376 = cos_a_0 > cos_b_0;
    float _S377 = _slang_select(_S376, 1.0f,_S375);
    return _S377;
}

__device__ float sine(float c_1)
{
    return (F32_sqrt(((F32_max((1.0f - c_1 * c_1), (0.0f))))));
}

__device__ float importance(LightNode node_0, float3  p_0, float3  normal_0)
{
    float3  _S378 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S379 = node_0.high - node_0.low;
    float3  _S380 = p_0 - _S378;
    float3  _S381 = ((((_S380)) * make_float3(rnorm3df(((_S380)).x, ((_S380)).y, ((_S380)).z))));
    float _S382 = dot_0(_S380, _S380);
    float _S383 = dot_0(_S379, _S379) / 4.0f;
    float _S384 = (F32_abs((dot_0(node_0.w, _S381))));
    float _S385 = sine(node_0.cos_theta_o);
    float _S386 = (F32_sqrt(((F32_max((1.0f - _S383 / _S382), (0.0f))))));
    bool _S387 = _S382 < _S383;
    float _S388 = _slang_select(_S387, -1.0f,_S386);
    float _S389 = sine(_S388);
    float _S390 = sine(_S384);
    float _S391 = cosSubClamped(_S390, _S384, _S385, node_0.cos_theta_o);
    float _S392 = sine(_S384);
    float _S393 = _S392 * node_0.cos_theta_o - _S384 * _S385;
    bool _S394 = _S384 > (node_0.cos_theta_o);
    float _S395 = _slang_select(_S394, 0.0f,_S393);
    float _S396 = cosSubClamped(_S395, _S391, _S389, _S388);
    bool _S397 = _S396 <= 0.0f;
    if(_S397)
    {
        return 0.0f;
    }
    float _S398 = - dot_0(_S381, normal_0);
    float _S399 = node_0.phi * _S396 / (F32_max((_S382), (length_0(_S379) / 2.0f)));
    float _S400 = sine(_S398);
    float _S401 = cosSubClamped(_S400, _S398, _S389, _S388);
    bool _S402 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S403 = _slang_select(_S402, 1.0f,_S401);
    return (F32_max((_S399 * _S403), (0.0f)));
}

__device__ float solidAngle(float probability_0, float3  normal_1, float3  toward_1)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_1)), (3.0f))) / (F32_abs((dot_0(normal_1, toward_1))));
}

__device__ uint pickChild(LightNode first_0, LightNode second_0, float3  p_1, float3  normal_2, float * pick_0, float * probability_1)
{
    float _S404 = importance(first_0, p_1, normal_2);
    float _S405 = importance(second_0, p_1, normal_2);
    float2  _S406 = make_float2 (_S404, _S405);
    bool _S407 = _S404 == 0.0f;
    bool _S408;
    if(_S407)
    {
        _S408 = _S405 == 0.0f;
    }
    else
    {
        _S408 = false;
    }
    if(_S408)
    {
        return 2U;
    }
    float _S409 = _S404 + _S405;
    bool _S410 = _S405 > 0.0f;
    if(_S410)
    {
        _S408 = (*pick_0 * _S409) >= _S404;
    }
    else
    {
        _S408 = false;
    }
    uint _S411 = uint(_S408);
    float _S412 = (F32_min(((*pick_0 * _S409 - float(_S411) * _S404) / _slang_vector_get_element(_S406, _S411)), (0.99999994039535522f)));
    *pick_0 = _S412;
    float _S413 = *probability_1 * (_slang_vector_get_element(_S406, _S411) / _S409);
    *probability_1 = _S413;
    return _S411;
}

__device__ float childShare(LightNode first_1, LightNode second_1, float3  p_2, float3  normal_3, uint child_0)
{
    float _S414 = importance(first_1, p_2, normal_3);
    float _S415 = importance(second_1, p_2, normal_3);
    float2  _S416 = make_float2 (_S414, _S415);
    float _S417 = _slang_vector_get_element(_S416, child_0) / (_S414 + _S415);
    bool _S418 = _slang_vector_get_element(_S416, child_0) > 0.0f;
    float _S419 = _slang_select(_S418, _S417,0.0f);
    return _S419;
}

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S420 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S421 = b_1 > 0.0f;
    float _S422 = _slang_select(_S421, _S420,1.0f);
    return _S422;
}

__device__ float sphereDensity(float3  center_0, float radius_1, float3  p_3)
{
    float3  _S423 = center_0 - p_3;
    float _S424 = radius_1 * radius_1 / dot_0(_S423, _S423);
    bool _S425 = _S424 >= 1.0f;
    if(_S425)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S424)))) / (6.28318548202514648f * _S424);
}

__device__ float3  sampleSphere(float3  center_1, float radius_2, float3  p_4, float u1_0, float u2_0)
{
    float3  _S426 = center_1 - p_4;
    float _S427 = radius_2 * radius_2 / dot_0(_S426, _S426);
    float _S428 = u1_0 * _S427 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S427), (0.0f)))))));
    float _S429 = 2.0f * u1_0;
    bool _S430 = _S427 >= 1.0f;
    float _S431 = _slang_select(_S430, _S429,_S428);
    float _S432 = (F32_sqrt(((F32_max((_S431 * (2.0f - _S431)), (0.0f))))));
    float _S433 = 6.28318548202514648f * u2_0;
    float3  _S434 = make_float3 (_S432 * (F32_cos((_S433))), 1.0f - _S431, _S432 * (F32_sin((_S433))));
    float3  _S435 = ((((_S426)) * make_float3(rnorm3df(((_S426)).x, ((_S426)).y, ((_S426)).z))));
    float3  _S436 = tangentToWorld(_S434, _S435);
    return _S436;
}

#undef Matrix
