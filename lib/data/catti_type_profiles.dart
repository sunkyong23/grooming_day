import '../models/catti_question.dart';
import '../models/catti_type_profile.dart';

const List<CattiTypeProfile> cattiTypeProfiles = [
  CattiTypeProfile(
    id: 'cherry_blossom',
    emoji: '🌸',
    name: '벚꽃냥',
    keyword: '따뜻한 호기심',
    title: '세상 모든 인연을 반갑게 맞이하는 냥이',
    description: '''
사람도, 새로운 공간도, 처음 보는 장난감도 반갑게 맞이하는 냥이에요.

세상이 낯설기보다 궁금하고,
새로운 만남 속에서도 금방 자기만의 리듬을 찾아가요.

집사 곁에 머무는 시간을 좋아하고,
작은 관심에도 마음을 활짝 열어 보여줘요.

밝고 따뜻한 호기심으로
하루를 조금 더 사랑스럽게 만들어주는 냥이랍니다.
''',
    targetSocial: 92,
    targetCuriosity: 88,
    targetActivity: 72,
    targetEmotion: 82,
    coreTraits: [CattiTrait.approach, CattiTrait.curious, CattiTrait.explorer],
    bonusTraits: [
      CattiTrait.follow,
      CattiTrait.talkative,
      CattiTrait.attention,
    ],
    traits: ['집사가 집에 오면 먼저 마중 나와요.', '새로운 것에 관심이 많아요.', '사람 곁에 있는 시간을 좋아해요.'],
    tips: ['짧게라도 자주 놀아주면 좋아요.', '이름을 불러주고 눈을 맞춰주면 큰 행복을 느껴요.'],
  ),

  CattiTypeProfile(
    id: 'kneading',
    emoji: '🧸',
    name: '꾹꾹냥',
    keyword: '애정 표현',
    title: '사랑은 말보다 꾹꾹이로 전하는 냥이',
    description: '''
사랑을 말보다 행동으로 전하는 냥이에요.

무릎 위에 올라오거나,
몸을 기대고 골골송을 들려주며
집사에게 조용히 마음을 표현해요.

편안하다고 느끼는 순간,
가장 부드러운 모습으로 곁에 머물러요.

작은 꾹꾹이 하나에도
깊은 신뢰와 애정이 담겨 있는 냥이랍니다.
''',
    targetSocial: 72,
    targetCuriosity: 28,
    targetActivity: 24,
    targetEmotion: 82,
    coreTraits: [
      CattiTrait.touch,
      CattiTrait.lap,
      CattiTrait.kneading,
      CattiTrait.purring,
    ],
    bonusTraits: [CattiTrait.trust, CattiTrait.comfort],
    traits: [
      '꾹꾹이나 골골송을 자주 보여줘요.',
      '몸을 기대거나 무릎에 올라오는 걸 좋아해요.',
      '집사 곁에서 편안함을 느껴요.',
    ],
    tips: ['스킨십을 편안하게 받아주는 시간을 소중히 해주세요.', '무릎에 올라왔을 때는 냥이의 속도에 맞춰주세요.'],
  ),

  CattiTypeProfile(
    id: 'zoomies',
    emoji: '⚡',
    name: '우다다냥',
    keyword: '넘치는 에너지',
    title: '하루를 가장 신나게 살아가는 냥이',
    description: '''
하루를 온몸으로 신나게 살아가는 냥이에요.

갑자기 우다다 달리기도 하고,
장난감 하나에도 눈빛이 반짝이며
순식간에 놀이 모드로 변해요.

에너지가 많지만,
그만큼 세상에 대한 즐거움도 큰 냥이예요.

충분히 뛰고 놀고 난 뒤에는
집사 곁에서 만족스러운 휴식을 즐길 줄도 아는 냥이랍니다.
''',
    targetSocial: 78,
    targetCuriosity: 92,
    targetActivity: 98,
    targetEmotion: 72,
    coreTraits: [CattiTrait.energy, CattiTrait.play, CattiTrait.explorer],
    bonusTraits: [CattiTrait.hunter, CattiTrait.curious, CattiTrait.attention],
    traits: ['갑자기 전력 질주를 시작해요.', '장난감만 보면 눈이 반짝여요.', '신나게 놀고 나면 편안하게 쉬어요.'],
    tips: ['짧게라도 매일 놀아주는 시간이 중요해요.', '에너지를 충분히 쓰고 쉴 수 있는 루틴을 만들어주세요.'],
  ),

  CattiTypeProfile(
    id: 'ribbon',
    emoji: '🎀',
    name: '리본냥',
    keyword: '사랑스러운 애교',
    title: '작은 애교 하나로 하루를 행복하게 만드는 냥이',
    description: '''
작은 행동 하나로 집사의 마음을 녹이는 냥이에요.

빤히 바라보거나,
짧게 야옹 말을 걸거나,
귀여운 몸짓으로 조용히 관심을 표현해요.

큰 표현보다 작고 사랑스러운 신호가 많은 냥이예요.

집사가 알아봐 주고 반응해 줄수록
더 밝고 다정한 모습으로 마음을 보여주는 냥이랍니다.
''',
    targetSocial: 78,
    targetCuriosity: 52,
    targetActivity: 42,
    targetEmotion: 72,
    coreTraits: [CattiTrait.attention, CattiTrait.talkative, CattiTrait.touch],
    bonusTraits: [CattiTrait.follow, CattiTrait.approach, CattiTrait.lap],
    traits: ['집사를 빤히 바라봐요.', '야옹으로 말을 걸어요.', '귀여운 행동으로 관심을 끌어요.'],
    tips: ['이름을 불러주고 칭찬해 주세요.', '짧은 눈맞춤과 반응도 큰 교감이 돼요.'],
  ),

  CattiTypeProfile(
    id: 'bread',
    emoji: '🍞',
    name: '식빵냥',
    keyword: '조용한 안정감',
    title: '말은 없어도 늘 곁에 있는 냥이',
    description: '''
말은 많지 않아도 늘 곁에 있는 냥이에요.

조용한 공간,
익숙한 자리,
따뜻한 햇살 속에서 편안함을 느껴요.

화려하게 표현하지 않아도
같은 공간에 함께 있는 것만으로 충분히 행복해해요.

잔잔한 하루 속에서
집사에게 조용한 안정감을 선물하는 냥이랍니다.
''',
    targetSocial: 35,
    targetCuriosity: 40,
    targetActivity: 25,
    targetEmotion: 75,
    coreTraits: [CattiTrait.calm, CattiTrait.rest, CattiTrait.routine],
    bonusTraits: [CattiTrait.sun, CattiTrait.stable, CattiTrait.comfort],
    traits: ['식빵 자세를 자주 해요.', '햇살이 드는 자리를 좋아해요.', '같은 공간에서 조용히 쉬는 걸 좋아해요.'],
    tips: ['혼자만의 휴식을 존중해주세요.', '조용히 곁에 있어주는 것만으로도 충분해요.'],
  ),

  CattiTypeProfile(
    id: 'cactus',
    emoji: '🌵',
    name: '선인장냥',
    keyword: '편안한 거리',
    title: '가까이 있고 싶지만, 조금의 거리는 남겨둘게요',
    description: '''
집사를 좋아하지만 자기만의 속도와 거리를 소중히 여기는 냥이에요.

가까이 있고 싶을 때도 있지만, 
혼자만의 시간을 보내며 마음을 정리하는 순간도 필요해요.

먼저 다가오는 날은 큰 용기를 낸 날일지도 몰라요.

그 작은 한 걸음을 기다려주고 존중해 줄수록,
조금씩 더 깊은 마음을 보여주는 냥이랍니다.
''',
    targetSocial: 35,
    targetCuriosity: 45,
    targetActivity: 30,
    targetEmotion: 40,
    coreTraits: [CattiTrait.personalSpace, CattiTrait.independent],
    bonusTraits: [CattiTrait.comfort, CattiTrait.calm],
    traits: [
      '만지다가도 슬며시 자리를 옮겨요.',
      '집사 근처에는 있지만 꼭 붙어 있지는 않아요.',
      '먼저 다가오는 날은 큰 용기를 낸 날이에요.',
    ],
    tips: ['먼저 다가가는 스킨십보다 기다려주는 시간이 중요해요.', '스스로 다가오는 순간을 존중해주세요.'],
  ),

  CattiTypeProfile(
    id: 'queen',
    emoji: '👑',
    name: '여왕냥',
    keyword: '당당한 품격',
    title: '사랑은 천천히, 신뢰는 오래도록',
    description: '''
자신의 선택과 속도를 존중받을 때 가장 빛나는 냥이에요.

아무에게나 쉽게 마음을 열지는 않지만,
한 번 믿은 사람에게는 오래도록 깊은 신뢰를 보여줘요.

다가오는 순간도,
물러서는 순간도 모두 냥이만의 표현이에요.

천천히 쌓아가는 관계 속에서
가장 고요하고 단단한 애정을 전하는 냥이랍니다.
''',
    targetSocial: 40,
    targetCuriosity: 45,
    targetActivity: 35,
    targetEmotion: 45,
    coreTraits: [CattiTrait.trust, CattiTrait.personalSpace],
    bonusTraits: [CattiTrait.observe, CattiTrait.independent],
    traits: [
      '기분이 좋을 때만 다가와요.',
      '만져도 되는 시간이 따로 있는 것 같아요.',
      '신뢰하는 사람에게만 속마음을 보여줘요.',
    ],
    tips: ['냥이의 선택을 존중해 주세요.', '스스로 다가오는 순간을 기다려 주세요.'],
  ),

  CattiTypeProfile(
    id: 'moon',
    emoji: '🌙',
    name: '달빛냥',
    keyword: '고요한 감성',
    title: '낮보다 밤이 더 따뜻한 냥이',
    description: '''
낮보다 조용한 밤에 더 따뜻해지는 냥이에요.

분주한 시간에는 멀리서 지켜보다가도,
밤이 깊어지면 집사 곁으로 조용히 다가와요.

창밖을 바라보거나,
곁에 머무는 짧은 순간 속에서도 마음을 전해요.

고요한 시간 안에서
천천히 깊은 교감을 나누는 냥이랍니다.
''',
    targetSocial: 60,
    targetCuriosity: 55,
    targetActivity: 55,
    targetEmotion: 70,
    coreTraits: [CattiTrait.observe, CattiTrait.comfort, CattiTrait.trust],
    bonusTraits: [CattiTrait.calm, CattiTrait.follow, CattiTrait.routine],
    traits: ['밤에 더 가까이 다가와요.', '조용히 집사 곁에 머물러요.', '창밖을 오래 바라보기도 해요.'],
    tips: ['밤의 교감 시간을 소중히 해주세요.', '조용한 스킨십이나 눈맞춤이 잘 어울려요.'],
  ),

  CattiTypeProfile(
    id: 'box',
    emoji: '📦',
    name: '박스냥',
    keyword: '끝없는 호기심',
    title: '상자는 들어가 보라고 있는 거잖아요?',
    description: '''
새로운 상자와 가방, 낯선 냄새를 그냥 지나치지 못하는 냥이에요.

처음 보는 물건은 꼭 확인해 보고,
작은 틈이나 숨을 곳도 금방 찾아내요.

조심스러움 속에도 호기심이 살아 있고,
탐색하는 순간 가장 눈빛이 반짝여요.

세상의 작은 변화도
놀이처럼 발견하는 귀여운 모험가랍니다.
''',
    targetSocial: 70,
    targetCuriosity: 99,
    targetActivity: 88,
    targetEmotion: 58,
    coreTraits: [CattiTrait.hide, CattiTrait.curious, CattiTrait.explorer],
    bonusTraits: [CattiTrait.highPlace, CattiTrait.energy, CattiTrait.play],
    traits: [
      '택배 상자를 보면 먼저 달려와요.',
      '새로운 물건은 꼭 냄새를 맡아요.',
      '가방이나 바구니 안에 들어가 있기도 해요.',
    ],
    tips: ['안전한 상자나 숨숨집을 마련해주면 좋아요.', '새로운 자극을 놀이처럼 제공해 주세요.'],
  ),

  CattiTypeProfile(
    id: 'explorer',
    emoji: '🔍',
    name: '탐험냥',
    keyword: '모험심',
    title: '세상은 아직 발견하지 못한 것들로 가득해요',
    description: '''
새로운 공간과 길을 발견할 때 가장 눈이 반짝이는 냥이에요.

문이 열리면 먼저 살펴보고,
높은 곳이나 낯선 구석도 조심스레 탐험해요.

집 안 곳곳을 자기만의 방식으로 기억하고,
하루의 작은 변화도 놓치지 않아요.

세상을 알아가는 일이
가장 즐거운 작은 탐험가랍니다.
''',
    targetSocial: 65,
    targetCuriosity: 100,
    targetActivity: 85,
    targetEmotion: 60,
    coreTraits: [CattiTrait.explorer, CattiTrait.highPlace, CattiTrait.curious],
    bonusTraits: [CattiTrait.energy, CattiTrait.hide, CattiTrait.play],
    traits: ['문이 열리면 먼저 확인해요.', '높은 곳에 올라가는 걸 좋아해요.', '집 안을 순찰하는 시간이 있어요.'],
    tips: ['안전하게 탐험할 수 있는 공간을 만들어 주세요.', '새로운 숨숨집이나 캣타워도 좋아요.'],
  ),

  CattiTypeProfile(
    id: 'lion',
    emoji: '🦁',
    name: '사자냥',
    keyword: '든든한 수호자',
    title: '작은 몸으로도 세상을 든든하게 지키는 냥이',
    description: '''
집 안과 가족을 조용히 살피는 든든한 냥이에요.

큰 소리로 표현하지 않아도,
창밖이나 현관 소리에 귀를 기울이고
집사가 어디 있는지 은근히 확인해요.

곁을 지키는 방식이 조용하고 차분한 냥이예요.

작은 몸으로도
자기만의 세계를 든든하게 지켜주는 냥이랍니다.
''',
    targetSocial: 68,
    targetCuriosity: 82,
    targetActivity: 58,
    targetEmotion: 50,
    coreTraits: [CattiTrait.observe, CattiTrait.highPlace, CattiTrait.stable],
    bonusTraits: [CattiTrait.trust, CattiTrait.comfort],
    traits: ['집 안을 자주 순찰해요.', '창밖이나 현관 소리에 반응해요.', '집사가 어디 있는지 확인해요.'],
    tips: ['안전하다는 확신을 주세요.', '높은 곳에서 쉴 수 있는 공간이 잘 맞아요.'],
  ),

  CattiTypeProfile(
    id: 'feather',
    emoji: '🪶',
    name: '깃털냥',
    keyword: '놀이의 즐거움',
    title: '세상에서 가장 행복한 순간은, 함께 놀아주는 시간',
    description: '''
움직이는 장난감 앞에서 가장 행복해지는 냥이에요.

낚싯대가 흔들리면 눈빛이 달라지고,
작은 움직임에도 집중해서 따라가요.

놀이를 통해 에너지를 쓰고,
집사와 함께하는 시간을 특별하게 느껴요.

신나게 놀아주는 순간마다
마음도 함께 가까워지는 냥이랍니다.
''',
    targetSocial: 70,
    targetCuriosity: 68,
    targetActivity: 96,
    targetEmotion: 62,
    coreTraits: [CattiTrait.play, CattiTrait.hunter, CattiTrait.energy],
    bonusTraits: [CattiTrait.curious],
    traits: ['낚싯대를 보면 눈이 반짝여요.', '움직이는 것을 잘 쫓아가요.', '놀이가 시작되면 집중력이 높아요.'],
    tips: ['하루 10분이라도 놀아주세요.', '놀이 후 쉬는 시간까지 함께해 주세요.'],
  ),

  CattiTypeProfile(
    id: 'cloud',
    emoji: '☁️',
    name: '구름냥',
    keyword: '여유로운 하루',
    title: '천천히 흘러가는 하루도, 충분히 행복한 하루예요',
    description: '''
서두르지 않고 천천히 흘러가는 하루를 좋아하는 냥이에요.

햇살 드는 자리,
조용한 창가,
익숙한 집사 곁에서 오래 머무는 걸 편안해해요.

큰 자극보다 잔잔한 시간이 잘 어울리고,
평온한 분위기 속에서 마음을 열어요.

함께 쉬는 것만으로도
충분히 사랑을 나누는 냥이랍니다.
''',
    targetSocial: 72,
    targetCuriosity: 38,
    targetActivity: 20,
    targetEmotion: 78,
    coreTraits: [
      CattiTrait.comfort,
      CattiTrait.rest,
      CattiTrait.stable,
      CattiTrait.routine,
    ],
    bonusTraits: [
      CattiTrait.calm,
      CattiTrait.observe,
      CattiTrait.personalSpace,
    ],
    traits: ['햇살이 드는 곳에서 오래 쉬어요.', '창밖을 멍하니 바라봐요.', '집사 근처에서 조용히 쉬어요.'],
    tips: ['같이 쉬는 시간도 좋은 교감이에요.', '조용한 환경을 만들어 주세요.'],
  ),

  CattiTypeProfile(
    id: 'nap',
    emoji: '🌼',
    name: '낮잠냥',
    keyword: '쉼의 행복',
    title: '충분히 쉬는 것도, 오늘을 잘 살아가는 방법이에요',
    description: '''
포근한 자리와 긴 낮잠 속에서 행복을 느끼는 냥이에요.

하루의 많은 시간을 쉬며 보내도,
그 안에는 이 냥이만의 안정된 리듬이 있어요.

따뜻한 담요와 조용한 공간,
집사 곁의 편안한 공기를 좋아해요.

잘 쉬는 시간이 곧
냥이가 하루를 사랑하는 방식이랍니다.
''',
    targetSocial: 70,
    targetCuriosity: 25,
    targetActivity: 10,
    targetEmotion: 74,
    coreTraits: [CattiTrait.sleep, CattiTrait.sun, CattiTrait.rest],
    bonusTraits: [CattiTrait.calm, CattiTrait.routine, CattiTrait.comfort],
    traits: ['하루에도 여러 번 낮잠을 자요.', '포근한 담요를 좋아해요.', '집사 곁에서 자는 걸 편안해해요.'],
    tips: ['편안한 잠자리를 만들어 주세요.', '쉬는 시간을 방해하지 않는 것도 사랑이에요.'],
  ),

  CattiTypeProfile(
    id: 'shy',
    emoji: '🌷',
    name: '수줍냥',
    keyword: '말없는 다정함',
    title: '마음을 전하는 데는 조금 시간이 걸려요',
    description: '''
마음을 전하는 데 조금 시간이 필요한 냥이에요.

처음에는 숨어 있거나 멀리서 바라볼 수 있지만,
그건 마음이 없어서가 아니라 천천히 확인하고 싶은 거예요.

믿을 수 있다고 느끼면
작은 걸음으로 조금씩 가까워져요.

서툰 표현 안에
조용하고 깊은 다정함을 가진 냥이랍니다.
''',
    targetSocial: 58,
    targetCuriosity: 40,
    targetActivity: 22,
    targetEmotion: 52,
    coreTraits: [
      CattiTrait.hide,
      CattiTrait.trust,
      CattiTrait.comfort,
      CattiTrait.follow,
    ],
    bonusTraits: [CattiTrait.approach, CattiTrait.calm],
    traits: [
      '처음엔 숨어 있거나 멀리서 바라봐요.',
      '믿는 사람 곁에서는 조금씩 편안해져요.',
      '표현은 작지만 조용히 마음을 보여줘요.',
    ],
    tips: ['먼저 끌어내기보다 기다려 주세요.', '스스로 다가오는 순간을 놓치지 말고 부드럽게 반응해 주세요.'],
  ),

  CattiTypeProfile(
    id: 'plant',
    emoji: '🪴',
    name: '화분냥',
    keyword: '변함없는 마음',
    title: '변하지 않는 하루가, 가장 소중한 선물이에요',
    description: '''
익숙한 자리와 반복되는 하루 속에서 편안함을 느끼는 냥이에요.

늘 머무는 곳,
비슷한 시간의 루틴,
집사의 익숙한 움직임이 냥이에게 안정감을 줘요.

큰 변화보다 변함없는 하루를 좋아하고,
천천히 쌓이는 관계를 소중히 여겨요.

평범한 일상 속에서
가장 오래가는 사랑을 키워가는 냥이랍니다.
''',
    targetSocial: 76,
    targetCuriosity: 20,
    targetActivity: 18,
    targetEmotion: 80,
    coreTraits: [CattiTrait.routine, CattiTrait.stable, CattiTrait.comfort],
    bonusTraits: [CattiTrait.follow, CattiTrait.sun, CattiTrait.rest],
    traits: [
      '늘 좋아하는 자리가 정해져 있어요.',
      '집사의 생활 리듬을 잘 따라와요.',
      '평범한 하루를 가장 편안하게 느껴요.',
    ],
    tips: ['반복되는 작은 습관을 소중히 해주세요.', '익숙한 하루가 냥이에게는 큰 안정감이에요.'],
  ),
];
