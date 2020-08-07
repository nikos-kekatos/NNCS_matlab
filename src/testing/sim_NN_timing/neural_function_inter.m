function Y  = neural_function_inter(X)
%NEURAL_FUNCTION neural network simulation function.
%
% Auto-generated by MATLAB, 15-Jul-2020 15:05:15.
% 
% [Y] = neural_function(X,~,~) takes these arguments:
% 
%   X = 1xTS cell, 1 inputs over TS timesteps
%   Each X{1,ts} = 6xQ matrix, input #1 at timestep ts.
% 
% and returns:
%   Y = 1xTS cell of 1 outputs over TS timesteps.
%   Each Y{1,ts} = 1xQ matrix, output #1 at timestep ts.
% 
% where Q is number of samples (or series) and TS is the number of timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [-3.23692918608157;-3.23692918608157;-3.23692918608157;-3.23692918608157;-114.358929362878;-114.358929362878];
x1_step1.gain = [0.337722106130249;0.337722106130249;0.337722106130249;0.337722106130249;0.00945442403649108;0.00945442403649108];
x1_step1.ymin = -1;

% Layer 1
b1 = [0.01461530418100989541;-0.011780312705234181198;-0.026109324853749744239;-0.012260314999629567945;-0.01228120547767160356;0.012716181517716147742;0.0098424722907822920215;-0.009293439760235897365;-0.0093526147213421721716;-0.010188810931426126732;0.0020148637997747494491;-0.035939856919184096085;-0.00063921295461836016849;-0.0056019744375637508735;-0.028054499212936644115;-0.017175904687156347966;-0.01919273111466434506;0.050970264835868125952;0.0015685905237646593797;-0.0072798400949955020117;-0.010290858934333532368;-0.005788420124007452594;0.0028775339408668109374;-0.014438285704210501031;0.012108575289279570678;0.031869317436314645309;-0.035115620254296014968;-0.011675067032276768841;-0.0012972233517618487249;0.012663601842640802644];
IW1_1 = [0.03782101654594086787 -0.034753932146481321397 0.022760141224162797058 0.014692007278072308218 0.031765121068100067581 -0.018114892099953042864;0.15061663829346896848 -0.20544891486961663896 0.078201052948016547273 0.0028394253790246736478 0.18837831467971438704 -0.066199098407236256492;-0.045832015078169051348 0.016105892727614583293 -0.026426580068567177839 -0.011790835814923615946 -0.05113897211709971663 0.011935871489078207427;0.12433830938518605769 -0.21583467686535426355 0.086092955899752104942 -0.011195387275631676557 0.20156403121235327847 -0.077423821199980841223;-0.036539825469540036795 0.044159673921100046912 -0.013808699905527993534 -0.0022025575590640857765 -0.022585010631414190879 0.028885211638070989321;-0.14729640271823032927 0.24233552072797706622 -0.11790933565050315535 0.006242426528310482739 -0.23979655769354785155 0.08261008704641104039;-0.011404882248878246004 -0.0061569179188221490398 -0.0011712110841065846711 0.0016393315656253455541 -0.016525858236032166942 -0.017763616034922036918;0.11055541861552248273 -0.10729564782553571711 0.03940122886117476686 0.017984925190002908069 0.10939813001930472069 -0.04334741337081128576;-0.13896321066101671726 0.10801510523530473418 -0.068265371291597237713 -0.014866942944832317597 -0.13065540212147566668 0.05092125523110094254;-0.13199189652693940622 0.11406383213324267079 -0.055759279010526921483 -0.01265497180295672465 -0.11206869226880261659 0.034168947333284377388;-2.6498985853918048325e-05 -0.031618689832450350141 0.00025395828685230995491 -0.012960072266927137943 -0.009888876119925225569 -0.026989760367592759843;0.40061322567139528994 0.15581920696153953032 -0.066318981072351970707 0.018547208191421759443 -0.087049685869157109042 0.10347669424052277631;-0.02815524611293961782 -0.015381497256489438247 -0.002494464881143506306 0.006182706048670255812 0.0057795311327050995914 -0.013928478804400198574;-0.13074887649052713279 0.25468517722961714345 -0.14117271422331470476 0.013781101084655536515 -0.29659504182184392995 0.13085530986580362622;0.17579870975742564743 -0.34049152018465561609 0.14355919392816102187 0.029137928133836421551 0.32920930316014285211 -0.13555697652237005957;0.10046641154427229936 -0.34276266348250417071 0.13958024441933031268 -0.020967356197950648422 0.2969033347123976041 -0.1178772334186806714;0.062101435519755984749 0.076938019948227479028 -0.021510837764189886384 0.031340299210718160217 -0.039388662630640870754 0.059549641346128209807;-0.1422088629861000264 0.004775509350650773005 -0.19355623995141921223 -0.084874125485460472085 -0.11345214516739628163 0.044797040572330928954;0.098081240143331027692 -0.062539500319893526203 0.036530099557228301599 0.0027398421608219110553 0.083555549539289647454 -0.040580788327551443884;0.12984899889960366259 -0.18440375378803536277 0.073237559993732895269 0.012878222125795717526 0.17988788406647152063 -0.056311274300044213137;-0.063478744164111006176 0.04647809211620231723 -0.035925480540181915778 -0.014371100544329598256 -0.044444314177283908429 0.019879823704113307181;-0.096410969221219527947 0.1034022378140240922 -0.045797085955476247998 0.01451939672184637993 -0.074060488324800027859 0.043897312762242492179;-0.09083866003364084174 0.067423313698579595554 -0.036481037669439525528 0.0014928277606006861225 -0.073200059658741448154 0.050089972681352491757;0.11444641050601342402 -0.23509983207712722986 0.12951033186548338572 0.0067465609890732369108 0.26154262014186213658 -0.10169785345949666766;-0.089102444302427488698 0.080846365683000465108 -0.022142495181488745792 -0.0071592847503338212511 -0.073391073959119521031 0.02123482364895914673;0.081379344182242338568 -0.14021346042793395026 -0.01333428513934381901 -0.06874102333890397265 0.045352066197733020836 -0.12095306122482891997;-0.10711186508570610942 0.1914114236738699848 -0.016864231366338959528 0.073622111038231644042 -0.087171165483865054036 0.1253788836601775758;-0.095447258287981368019 0.073029875857455406329 -0.041342762046663289466 -0.023170359120788956708 -0.089667603348498201021 0.021870013602251891366;0.10577775844435581554 -0.13483890559244265939 0.083242778671235029275 0.021819234098634933405 0.13134793808443245844 -0.051827964849203246589;-0.054699143064127750402 0.04569233788003813912 -0.019359599542621078183 -0.0089264996235698251814 -0.054054043480908135766 0.02186248454292455054];

% Layer 2
b2 = [0.00058657662370601836715;0.0078670550986307159758;0.0094494635794124537398;-0.013832870124138030299;0.0072416323206841437532;0.0056882787244532939663;-0.0033267949229990895904;-0.0016747083057589769606;0.0056688736452939827992;0.0014558693436582685523;0.0078911957114528342994;-0.0066877544506653303219;0.0090854699676934640856;-0.00048972064616392186904;-0.006041757477628797654;-0.0047554612678389965308;-0.0052612645127095751876;0.0051995336729882615789;0.00089703812935682154545;-0.0070391171905814361662;0.010828584035053032131;-0.0078880005841711550718;0.0038604863727787624983;0.0045298372998795197533;0.0059014296466520068177;-0.0080697683962301178934;0.010933955790516742754;-0.035920043137769502861;0.0068152767926966083267;-0.013376033932146961028];
LW2_1 = [-0.0099690958896069947065 -0.043438681330871538322 0.012356728026715451882 -0.046809170819918283213 0.0098891188454799799912 0.055798045080652745875 0.0042450738244426220597 -0.02857983910114625728 0.03302189621776152606 0.030767269491969340134 0.00079741431602975789729 0.010109623452436867358 0.0062994370693842515613 0.058984267498733963797 -0.068729604652722126046 -0.064162869322040239073 0.0012625204627191800779 0.033159527499187130273 -0.015525421402699562251 -0.045653450424691308096 0.018146719304079041851 0.027680218706358269976 0.017883488469216182737 -0.060524683129887318911 0.020740755840697063656 -0.017387408857386505573 0.038597336705875812113 0.027400742437632588655 -0.037416269831593608475 0.0069649089503517804672;-0.0037522446627979016975 -0.012177719274143426753 0.0024944764658357551981 -0.011725353237016492361 -0.00045348162440519550762 0.014391418864113107029 0.0025957375610457097612 -0.010961875609732208564 0.0079209225765182605938 0.0063043735369124999715 -0.0020016972435235227262 0.003672481080609273172 0.0024262088690276024938 0.019433550358350783899 -0.020894614091548992935 -0.015160491169313406942 0.0010189628926378152193 0.0086578640780972729307 -0.0058514587535980098695 -0.0087364284294794460062 0.0063739015317040024003 0.0052631903788156100127 0.0075521779994604113298 -0.015865079967134824296 0.0028523429737939910884 -0.0016546751324073454871 0.0089270666671162537259 0.0094467999940175666901 -0.0076608672797372802388 -0.00033072860142726060936;0.0050624665157215763961 0.045041777981340631876 -0.011554545063069455307 0.0474228507073597913 -0.0033788649691021506102 -0.050715733961117150097 -0.0057947152507823876735 0.028734027480365784135 -0.033207504768592500943 -0.032107918716981716234 0.0010865360050212153568 -0.010406824996269152528 -0.012728419331127708083 -0.061004303018438947592 0.069402679597114561028 0.065071828408956283729 0.00031864654376704626762 -0.033473237795386995286 0.018042268656460545839 0.042176382141443390095 -0.018281553761903962529 -0.023372373246243367817 -0.013900525745704812516 0.053261819408024477229 -0.021187402850873691962 0.018483918126713082958 -0.035243950371516459541 -0.021261059138603200652 0.034194420706742389982 -0.0083847962120682188042;0.016365845054908637057 0.10171363723658352618 -0.016100691288607384827 0.11294247377713789726 -0.019986117910318668828 -0.12583183204369585706 -0.0027688207455948939464 0.064149233599364113845 -0.072755944115882292822 -0.068236512385548564463 0.0066535867933515497816 -0.084881648560068578835 -0.0013442602906193982376 -0.144605359358377622 0.16453841796793988728 0.16093782437148976272 -0.029312866210429604219 -0.056491666420417405159 0.041794174556729069003 0.094920214293981397535 -0.02456228200329746425 -0.049982709378272739686 -0.043476319505279935329 0.12766997505403171465 -0.050398190586139389457 0.05772287281212325899 -0.075732034323104033269 -0.046565518865840510587 0.065432563592931952678 -0.03216675806204473409;0.012408092731177346874 0.074783361137891316006 -0.014360841725026505036 0.080817278343997170365 -0.011965017784053887454 -0.093827209880252449015 -0.0051664896715087641962 0.043756612242598809381 -0.050751414121427425308 -0.048607631909558988992 -0.004662004557604400995 -0.046391607898819964273 -0.0098553815335736486697 -0.11027839761465517421 0.11615159367912721022 0.10875127143342488978 -0.0019376892489034571246 -0.051244808179449784225 0.031841672702140465245 0.070425387719468268699 -0.018654879013642770152 -0.037349541202280039931 -0.033485412663800950828 0.096265317099863065287 -0.034605089204141369075 0.041252370408647237587 -0.060420227682681175441 -0.036023566945856337618 0.052370347725318025511 -0.024300487036660066431;0.019425670355034539011 0.077312061706577769882 -0.017176726798383432082 0.084207951636800421058 -0.014516246881415588096 -0.093855668195428815226 0.0017073182534561024467 0.050584001268751233038 -0.060294953983845482604 -0.050471927944114480802 0.0047922470231637967486 -0.048937126624263131702 -0.0059165606510131049309 -0.10909231703197758145 0.12282052425823247743 0.12278308445889954403 -0.010726245552752370488 -0.050178891307679406031 0.032612310537865132898 0.073733324224711266348 -0.025540288284797461188 -0.04105609371487174003 -0.03133132205025779965 0.1013301436316275117 -0.028478788061140989513 0.035876618352811931456 -0.065125328320123535009 -0.043491556635194675295 0.061630408047479413869 -0.023451064579680710315;-0.01126601748967138647 -0.074137548694586982712 0.015214150666038733783 -0.082622738259655617576 0.012775190957663965993 0.086216479142717919459 0.0075739938875743796631 -0.049812927559388722742 0.049654474151154627537 0.052146429150691647747 -0.0022744139159603074703 0.037827672102937408283 0.011735195662191152954 0.10385206528614955579 -0.1127952102179155397 -0.11443480480183168546 0.0056740647821600879303 0.045678235983135931364 -0.031957414619790062982 -0.067611007712797918656 0.026895066866324160437 0.040050109505787842568 0.02531062262940356189 -0.09236213189607384022 0.035058694649844311664 -0.037983286522182989342 0.055130306423519653825 0.036174220254772106176 -0.051838744571407371908 0.019434452863606097722;-0.013906439039391389062 -0.070937606620275928115 0.01960200451230103072 -0.081340490276200314024 0.012883333962141845647 0.089786232905637128332 0.0053383279137153502591 -0.043525617471571562134 0.056612583308119419911 0.047416160682969797635 -0.0042659782703535929424 0.044659680995057314534 0.0083064410826578765484 0.10851347646792580681 -0.11534059019188333539 -0.11155066559726325992 0.0043995778715962769248 0.044479951442751547441 -0.034961843544198963063 -0.065461486779022234894 0.021123839705033890801 0.036407801976374200292 0.035327158949435083501 -0.096997159960641898824 0.031491737107546144414 -0.04037725955110431364 0.056899678769624296992 0.034852952404608956993 -0.052977961324659733622 0.024532497686390319913;0.00046371240024440448131 0.0056504365942459831504 -0.0017073113326718065367 0.0058262191752750857807 -0.0043605180214651480947 -0.0063531490816387337431 -0.0027402996197307908505 0.0050282560790453926722 -0.0022947312616736132741 -0.0068625377772437035767 0.002882471072076787412 0.0014729620329425974039 -0.0044205138270900614164 -0.0078498972692683018776 0.011209650486029858543 0.01142749201271036491 -0.0019209242313688794195 -0.0051276944699829400676 0.0057464637311239004022 0.0082826468605659286926 -0.0012260668049650297936 -0.0043603052865100093774 -0.0018256467043034139801 0.0088882007876358876813 -0.0010513349544591594001 -0.00070097079866055238447 -0.0064940350492482699571 -0.00637812999589454626 0.0025028662167813756946 0.00067771472169270846608;-0.0048030001326683840687 -0.015985715045457135619 0.0055527150324733301825 -0.01931607412857443834 0.00054377024407479450721 0.020086517255291556905 0.00026863905230642117156 -0.010597444838560907479 0.0087344566581412080158 0.0081860284766686521735 -0.0034914711128306678833 -0.00050365526793397360703 0.0051179535535152481315 0.021204010654283542842 -0.025007227361323370457 -0.018971047335399351952 -0.00055289042458242206382 0.013167196045930701018 -0.0066199546374669064608 -0.010610588200425298544 0.0070983326676049814455 0.0080114752618529582601 0.0056081078240905971738 -0.020325890708247914412 0.0078634126174529275083 -0.0085777211947459259395 0.013550064896495952679 0.0068349449099386920189 -0.0096378789908160289457 0.0062158575669300315455;-0.023592085949986119769 -0.09929532973257781947 0.027453545124414984596 -0.10512772390955658908 0.018921173192319049039 0.12116892532491965739 0.00015410664037312263005 -0.057750125859260356687 0.076876377366938905555 0.063100999991963530045 -0.012468654910587450083 0.092214075669809214553 -0.0010939092166573709773 0.13963148503633984743 -0.15773003208182548307 -0.14923994350089250793 0.027818037038235668423 0.057118981691687532865 -0.044233137635654146136 -0.091731690291335724052 0.027801791284840667723 0.052827590078197927959 0.037652177679354900675 -0.12597135154693822612 0.041438740948730998226 -0.055604255020415174759 0.076145068463011389426 0.047657769137647749969 -0.067384149141176213904 0.030093233205677288183;-0.0092560940428647996842 -0.054235337226500632268 0.012855546666048206852 -0.058246533963746321971 0.0084270641924258319483 0.063136805563064862801 0.0050769726716158826083 -0.0311837508178752984 0.040177462564053051386 0.030857113903493892798 -0.0031791957836132416805 0.016122149616664593202 0.0092875700470679278808 0.076037657368626665466 -0.081590194380197086921 -0.082553169887883262601 0.00036267049718726401082 0.037405569981308686711 -0.023608725189263397165 -0.049955668516011172975 0.016917595191079791428 0.024943885401086832859 0.019632594517567943104 -0.069749683607994730772 0.024201477763378036884 -0.024753358180969062263 0.041511074909333860183 0.032934356164821626534 -0.040247998371549749408 0.012464093603140834893;0.019482289944400116993 0.07504592961127581896 -0.018414835991514520719 0.080837642262300418716 -0.013887032143118812483 -0.089293489226867375774 -0.0036970907795367217302 0.048830006775870883617 -0.057169113830153002465 -0.049129962841601301782 -0.0012375558754663315824 -0.053228487352983223924 -0.0051335468782260562301 -0.11617636445838108727 0.12405923915914589262 0.11045847213016202204 -0.0049040847910841699198 -0.047236404317624443305 0.039260213466577903452 0.067329863634102968262 -0.018712800334225874327 -0.04283365093869689888 -0.032593422177361192071 0.1017918914486058285 -0.03095718435134240179 0.042845454120797779596 -0.067905705892148893188 -0.041768891238753561024 0.058342621516806511539 -0.020595814931538124898;0.0013340277706832630832 -0.0011653745663074905389 -0.0044559163291762555678 0.00059136275581005723432 -0.0028326913277713079535 0.00058174588683377714392 -0.0016184302884413095946 -0.0027457118230224241556 -0.0034153596897580750652 -0.0035423487016038026839 -0.0027934637689195451586 0.0016507229625999126233 0.0022801401853758526336 -0.00013005869808890041408 0.0037961059689203754952 0.00032981964279686946462 0.00067144508996563097986 0.0016250568292244340664 0.00047840702567207419628 -0.0009201509273599309301 0.0015182605190327336849 -0.0012666660192932838267 0.0019113862177484299085 -1.7599834234695536787e-05 0.0031123752884763267179 -0.0030290520555593422429 0.00026250967690277484312 0.0012509448667789287244 0.0034259839036444392907 -0.0012692879799660571061;-0.013541425571979872483 -0.068851777054861174054 0.008904826502353338849 -0.070879320142484478207 0.01159782217062798812 0.079300235413598541001 0.0043405517812823745175 -0.041014333270077925342 0.042483379701036869114 0.044075899759572406689 -0.0039601841287132347885 0.024269279902050220482 0.012162566322900464702 0.089817892759626566379 -0.10256646215550845047 -0.10307637711882446097 -0.0010230016264160305371 0.042424758550694115222 -0.022184767292476582218 -0.066493727856440712487 0.019908127892824950544 0.038122815218132433124 0.021081187623249092455 -0.08110230941555902906 0.025538943504518948902 -0.027396071161346246398 0.056110335788471660257 0.03393759593137609526 -0.052143783597436273169 0.01797429231473470293;-0.0089222183513519362497 -0.070067585063640164256 0.014088927588685998607 -0.077180049623919902424 0.012166834774718617018 0.083434553001939540384 0.0025229105378666411529 -0.044019254252670746153 0.052832628777090794026 0.051164732580679321561 -0.0010296151696215312312 0.028347925341264120641 0.012027967613849400649 0.097974718876665756184 -0.10894747896781396823 -0.10383439790999662855 0.0079906753187648157932 0.047505250356950794177 -0.028895280178096862528 -0.063335625803425471547 0.022493033570727780091 0.033512750757456043205 0.029747646058576524691 -0.090895377232132687495 0.028655349428868968215 -0.029521839649132103345 0.053787864150499804794 0.038768824260189890807 -0.053337257511312255454 0.014942168358687068358;-0.0090269511357452762029 -0.057125129299306652564 0.014668089259146435688 -0.062034385438983499772 0.010838104099317284745 0.065657993166965064602 0.0053566137522475408203 -0.03211033971288268507 0.036132498128041985741 0.036054193107892637538 0.0012161762636618425951 0.017525975195187958738 0.0087046035327468032627 0.077686993769167753121 -0.087172501879223901478 -0.085927861182520284822 -0.0032643159653679876438 0.036849002624753234014 -0.024158147361155641458 -0.051944221422361006035 0.017414787668336283166 0.027596121656513660642 0.018170511621752455378 -0.072347856882913549881 0.023895164071182677795 -0.026168010145314429121 0.046050492080496691072 0.028782335005526033661 -0.044154045716863654647 0.013769349004808023942;0.0053963763836652311329 0.041481610355575536386 -0.0051928522596965537295 0.042688581410934921256 -0.0094206864188154208761 -0.048294658907985336949 0.00087815082932920390281 0.024052511473303322259 -0.027827476833773710091 -0.024856457081060760739 -0.0019943469879607775633 -0.013281672751645361846 -0.012570844766186514696 -0.056843014704686056771 0.06053124417398002971 0.060107055185860215618 0.0077024637700415883243 -0.032626286930888967475 0.016663737033437583945 0.039313651510846016335 -0.016677906831229903639 -0.018866805606280422081 -0.018173053371140203416 0.050519186331203315421 -0.017502765791203352824 0.017765185413438494555 -0.02939711918037300406 -0.020566556661086608793 0.02839013841641735425 -0.011243372247807435771;0.0024774871452363754487 0.019676624152423629471 -0.0009335820165417332275 0.022158061181957167812 -0.0032732052376481771301 -0.022631181382458512991 -0.0014183531785857750925 0.014907819476654931776 -0.016333451106351194043 -0.011298779824940496236 0.0024983419749728245397 -0.0060260105831239961852 -0.0039648574680500687714 -0.030132486847393964019 0.028521292857716051133 0.033530663022823023467 0.00017749101677375458443 -0.013358778451454203853 0.0067399250666363205026 0.015893319121041842718 -0.010480529330856910158 -0.012079505364659598454 -0.0097036582684791906905 0.024833528118817779079 -0.01057685286661357027 0.005480037914181175307 -0.018114994732964406765 -0.012857338944926788998 0.015536791164569600451 -0.0022200738758517846866;-0.0089572181277521797926 -0.045282943046161448775 0.007260465817540879413 -0.047553072305711457934 0.0054295467994088840794 0.057335490671253631911 0.003662469945982454924 -0.032045129359826431126 0.035058301142096612302 0.030155034655777603059 0.0018163895857198624362 0.010011103258578383027 0.0074690221500826776968 0.060507077876749588985 -0.068392850111413966419 -0.070072406278992929729 -0.00059860775804107427094 0.030134932803635119947 -0.021755314507728155948 -0.046895616243765210485 0.017653065384940117011 0.023194237987081048336 0.020290957548654463966 -0.059795885513890256746 0.021503106622456899522 -0.020244635496760188947 0.038825024630436841266 0.023121402051459665622 -0.035559749040460358893 0.0084103349834545419739;-0.022325147633320004126 -0.10489537519402650223 0.028197958900199663473 -0.11703373888661396107 0.023226298716382317439 0.13379152374785391322 0.002437806833047262943 -0.062721010780467656431 0.07628386895640655585 0.07277857325354242235 -0.007284573710928807927 0.10897399941179894411 -0.0046499453402549109984 0.15334873388195741084 -0.1756958081473921629 -0.17182408010886551786 0.044391202123923306777 0.049749240425446331071 -0.044415914768499792364 -0.10403361127276292142 0.026144996803242451927 0.053642598139627482856 0.043920222941462853938 -0.13707635222172501188 0.046881621749307683666 -0.062545094037576562385 0.091676298640657627459 0.058706125383084763192 -0.071781963351899180648 0.033470772549818346431;-0.0070019872559646907303 -0.052370361887210593876 0.0093171616398035356915 -0.059878882304074336485 0.0076609004394114941713 0.065971469052902770303 0.004641248837351604449 -0.036060589884304938835 0.040250952092289099538 0.033666289533092336184 -0.0015062698527112533542 0.01493642236200672796 0.0095012365029724168974 0.073919884954257164544 -0.084259797495187832572 -0.077353022689519032595 0.0028081117652361065398 0.034699513030861654783 -0.019141224490207796316 -0.051455283189207688677 0.021663646939602865943 0.025127880218860015188 0.022921605525609026199 -0.064847722103375429747 0.01816884225276739484 -0.026058264997972840904 0.043410731715702519096 0.030109508131852525531 -0.039581330768078584748 0.013783047175309051657;0.008922558415396993417 0.054823907698849767833 -0.01234533612330090957 0.061952133280169040253 -0.010950273541938532196 -0.068248997882502923651 -0.0050046641304542435758 0.038921190818579885773 -0.041407370180972166707 -0.039984284246402997109 0.00079869979155902973925 -0.021287430648831255631 -0.013798014581651748406 -0.078622295014911108835 0.088537793900140826509 0.087495771185362627986 0.0016183702152052096071 -0.034232099403210376753 0.026252827196374280833 0.052016842300633372997 -0.023096151230820760603 -0.031605128480891336862 -0.020428585362186810898 0.073739603056614921872 -0.026193455102780691113 0.024809499336302647671 -0.050389250216362105328 -0.035597057032048073921 0.043178507027387263983 -0.012154292033792878786;0.0040395330237600864456 0.046670814237722693663 -0.0092260557183430937089 0.053839850156447911778 -0.0017239981766958528513 -0.062305174744667887743 -0.0056792904822391748407 0.027533079572331486257 -0.029358242571479287175 -0.033391454138269251184 0.0051203987893582688165 -0.012025995435784838164 -0.010198754111810787171 -0.063247660949786663198 0.067693329099147409034 0.071802708043096546975 5.7515312982580289996e-05 -0.033829232235398555562 0.019631658107320221901 0.042253066275925420248 -0.017868387409522921982 -0.026359954116972755811 -0.016509032874172775707 0.059226540628303084302 -0.017302954312712601204 0.018901876449559696508 -0.038220003782977407525 -0.026346721772286897656 0.035682959558305152314 -0.014603735918910829006;0.012323858612486953551 0.066774395487882123867 -0.01251781687654877212 0.07157582859442623846 -0.015745591404149810594 -0.077261125336250083273 -0.00011385895334844445183 0.040947137154858370689 -0.045663040285118132455 -0.047210775718439929038 0.00071410598139394845536 -0.031895628897277455982 -0.010998118441939644038 -0.094210584079807285773 0.10456484322213709104 0.098311058299312081843 -0.0032571749137402291469 -0.049281304487926828883 0.029198954891087227498 0.061900054426750505954 -0.020617884739668457944 -0.039130536924356647266 -0.026394418352402755634 0.08741836151791879117 -0.023626003549415117155 0.029925541431287745048 -0.051853788137441868267 -0.035896283927076340359 0.054242272665542136389 -0.01793033205739261865;-0.0030932842943322230549 0.0043855703441568671605 -0.0013425616280654786763 0.0012374586227711596026 0.0025143862187062644351 -0.0047240715000866064996 -0.0028750591038621468691 0.0017077306797268908441 0.001223224812869225242 -0.00011859379872967356847 -0.0029039488563745046758 -0.0010593702692394178864 0.0016590367847584162539 -0.0031441120513493272561 0.0067949694914322998976 0.002136691561650178213 -0.00022236853541665520815 -0.0004642398259632934455 -0.0002725383696962858579 -0.00016743538076146528403 -0.0042110074405838889347 -0.0032313794513251273798 0.00022395727009309529315 0.00063955571476534693771 -0.0013805196065281557984 0.00043061962187718779826 -0.00044929656940397369458 -0.00094275891571449579615 0.0045364711157076260256 0.00065693072318263857033;0.0056363548503879793219 0.019252577747234652511 -0.0093560141020328606298 0.023903719725423783898 -0.0010354325380434801877 -0.023642147194881200228 -0.0014647016857373905928 0.014337403567604252094 -0.013438061136040827317 -0.012545725030413869966 -0.0012651636627286201673 -0.0039256328872785649364 -0.0076389447119797806302 -0.031705895355046587181 0.029220051892387504527 0.02833260599814173622 0.0030381918991303591242 -0.014335150093128669335 0.0060040528847184349709 0.023513048580186955705 -0.012221563195009155917 -0.01101088696413325338 -0.0071490880963198163295 0.024639450552530514638 -0.0061779655706558555747 0.0076321927960517760292 -0.014036181928938230162 -0.0098605191776216655208 0.015256444338478074643 -6.5100174779872768162e-05;0.027196517107282273257 0.12836947054564532 -0.023547537338529461737 0.14408620446072331611 -0.023200570703114729854 -0.15982395076724267846 -0.0078460167686036277196 0.081393530800762559085 -0.090931609368201243848 -0.08375038974154894178 0.015057133182927910989 -0.15591791978200789104 0.007514163407835232518 -0.18052647393852339075 0.21294526299024249538 0.20584123450989916249 -0.062627645113191063309 -0.061557054710246042473 0.05709201012057359137 0.11245250165801765063 -0.027195356861397214365 -0.059815963603558959527 -0.057337347597198856652 0.16485886388708581585 -0.065326122876709219467 0.078502723635282781189 -0.09604467507024049 -0.055790198033681771828 0.079709726557517235346 -0.05150850796270247528;0.010593281717905338873 0.063003236813655300042 -0.0084673840958560380593 0.065574840536547412961 -0.0094369630218725849419 -0.07236995822209708884 -0.0066082512281953834782 0.042265636018235727689 -0.043131184039304049094 -0.038651783314574146566 0.0039330322162611239603 -0.020617106989986085791 -0.010380786749874500521 -0.08533168589421108452 0.096352782524811414477 0.09314300237054443099 -0.00039231002051626841535 -0.037980319201687463837 0.0269486281957870763 0.060464201805684465729 -0.01928489117861031249 -0.027541854721766026448 -0.026494221993166068574 0.07916762312461821105 -0.02943184862995371423 0.02388096996324445831 -0.049627045772499413234 -0.029238634226468798033 0.047291687840553514599 -0.017911932080124495781;-0.0048867838474356967149 -0.025209322935992657666 0.0054843575024424301434 -0.026425961656835288832 0.0013763207250971328313 0.030856007215590928322 0.0042571918638407034094 -0.017056703553442926352 0.019024116073846884106 0.019879733033751654375 6.0539490779773643498e-05 0.0025205744766497346909 0.0057203093752000817515 0.035851152494956295413 -0.042014511419361626199 -0.041570929848438679943 -0.0056219659828098218421 0.018138577156521416833 -0.010757028126781581837 -0.027363483285969526781 0.010522134727908494592 0.015407360264651162249 0.010501889661265894835 -0.034007693138560578239 0.01376103875448465505 -0.0064081737122753156324 0.018001852193378332923 0.018161776204043460214 -0.019247706864401987331 0.0024774000181113833147];

% Layer 3
b3 = 0.045641334123884762242;
LW3_2 = [-0.19269156036112200514 -0.049673809908669298852 0.18485116681530638916 0.465991434890299705 0.32368564143412748013 0.3543986800345099164 -0.31665523565742864642 -0.32303767809463118654 0.02601632921724104236 -0.065593314339947583758 -0.47899365441597951953 -0.23418115097041783401 0.33447170629199524106 0.00085090268025550357123 -0.28019722820482401149 -0.30974105436148902104 -0.23665471024884959794 0.1732886896947160027 0.085305287660643255854 -0.19787913165172982266 -0.52390504391287706643 -0.22547876724597734621 0.24686393065506326283 0.19962540786006763294 0.29108408262865104188 0.0036416822315156077185 0.084381354243935377535 0.61988450998855704199 0.2629101318959552458 -0.1106368798324906394];

% Output 1
y1_step1.ymin = -1;
y1_step1.gain = 0.00945442403649108;
y1_step1.xoffset = -114.358929362878;

% ===== SIMULATION ========



% Dimensions
TS = size(X,2); % timesteps
if ~isempty(X)
  Q = size(X,2); % samples/series
else
  Q = 0;
end

% Allocate Outputs
Y = zeros(1,TS);

% Time loop
for ts=1:TS

    % Input 1
    Xp1 = mapminmax_apply(X(1,ts),x1_step1);
    
    % Layer 1
    a1 = tansig_apply(repmat(b1,1,Q) + IW1_1*Xp1);
    
    % Layer 2
    a2 = tansig_apply(repmat(b2,1,Q) + LW2_1*a1);
    
    % Layer 3
    a3 = repmat(b3,1,Q) + LW3_2*a2;
    
    % Output 1
    Y(ts) = mapminmax_reverse(a3,y1_step1);
end




end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
  y = bsxfun(@minus,x,settings.xoffset);
  y = bsxfun(@times,y,settings.gain);
  y = bsxfun(@plus,y,settings.ymin);
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
  a = 2 ./ (1 + exp(-2*n)) - 1;
end

% Map Minimum and Maximum Output Reverse-Processing Function
function x = mapminmax_reverse(y,settings)
  x = bsxfun(@minus,y,settings.ymin);
  x = bsxfun(@rdivide,x,settings.gain);
  x = bsxfun(@plus,x,settings.xoffset);
end