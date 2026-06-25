import '../models/catti_question.dart';
import 'catti_trait_presets.dart';

const List<CattiQuestion> cattiQuestions = [
  // ------------------------------------------------
  // 사람과의 관계
  // ------------------------------------------------
  CattiQuestion(
    id: 'Q1',
    number: 1,
    category: '사람과의 관계',
    icon: '❤️',
    text: '집사가 집에 돌아오면 우리 냥이는?',
    options: [
      CattiOption(
        id: 'A',
        text: '현관까지 마중 나와요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 3),
          CattiScore(axis: CattiAxis.emotion, value: 2),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.approach, value: 3),
          CattiTraitScore(trait: CattiTrait.follow, value: 2),
          CattiTraitScore(trait: CattiTrait.attention, value: 1),
        ],
      ),
      CattiOption(
        id: 'B',
        text: '잠깐 쳐다보고 근처로 와요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 2),
          CattiScore(axis: CattiAxis.emotion, value: 1),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.approach, value: 2),
          CattiTraitScore(trait: CattiTrait.trust, value: 1),
        ],
      ),
      CattiOption(
        id: 'C',
        text: '관심 없는 척하다가 나중에 슬쩍 와요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -2),
          CattiScore(axis: CattiAxis.emotion, value: -2),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.observe, value: 2),
          CattiTraitScore(trait: CattiTrait.personalSpace, value: 1),
          CattiTraitScore(trait: CattiTrait.observe, value: 1),
        ],
      ),
      CattiOption(
        id: 'D',
        text: '자기 자리에서 계속 쉬어요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -3),
          CattiScore(axis: CattiAxis.activity, value: -2),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.independent, value: 3),
          CattiTraitScore(trait: CattiTrait.rest, value: 2),
          CattiTraitScore(trait: CattiTrait.calm, value: 1),
        ],
      ),
      CattiOption(id: 'E', text: '상황에 따라 달라요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q2',
    number: 2,
    category: '사람과의 관계',
    icon: '❤️',
    text: '집사가 소파나 침대에 앉으면?',
    weight: 1.2,
    options: [
      CattiOption(
        id: 'A',
        text: '바로 무릎이나 옆으로 올라와요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 3),
          CattiScore(axis: CattiAxis.emotion, value: 3),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.lap, value: 3),
          CattiTraitScore(trait: CattiTrait.touch, value: 3),
          CattiTraitScore(trait: CattiTrait.trust, value: 2),
        ],
      ),
      CattiOption(
        id: 'B',
        text: '같은 공간 가까운 곳에 자리 잡아요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 2),
          CattiScore(axis: CattiAxis.activity, value: -1),
          CattiScore(axis: CattiAxis.emotion, value: 1),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.comfort, value: 2),
          CattiTraitScore(trait: CattiTrait.follow, value: 1),
          CattiTraitScore(trait: CattiTrait.trust, value: 1),
        ],
      ),
      CattiOption(
        id: 'C',
        text: '멀지 않은 곳에서 바라봐요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -2),
          CattiScore(axis: CattiAxis.emotion, value: -2),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.observe, value: 3),
          CattiTraitScore(trait: CattiTrait.personalSpace, value: 2),
        ],
      ),
      CattiOption(
        id: 'D',
        text: '혼자 쉬는 자리를 더 좋아해요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -3),
          CattiScore(axis: CattiAxis.activity, value: -2),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.independent, value: 3),
          CattiTraitScore(trait: CattiTrait.personalSpace, value: 3),
          CattiTraitScore(trait: CattiTrait.rest, value: 2),
        ],
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q3',
    number: 3,
    category: '사람과의 관계',
    icon: '❤️',
    text: '낯선 사람이 집에 오면?',
    options: [
      CattiOption(
        id: 'A',
        text: '먼저 다가가 냄새를 맡아요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 3),
          CattiScore(axis: CattiAxis.curiosity, value: 2),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.approach, value: 3),
          CattiTraitScore(trait: CattiTrait.curious, value: 2),
          CattiTraitScore(trait: CattiTrait.explorer, value: 1),
        ],
      ),
      CattiOption(
        id: 'B',
        text: '멀리서 관찰하다가 천천히 다가가요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 1),
          CattiScore(axis: CattiAxis.curiosity, value: 1),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.observe, value: 2),
          CattiTraitScore(trait: CattiTrait.curious, value: 1),
          CattiTraitScore(trait: CattiTrait.trust, value: 1),
        ],
      ),
      CattiOption(
        id: 'C',
        text: '숨어 있다가 시간이 지나면 나와요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -2),
          CattiScore(axis: CattiAxis.curiosity, value: -1),
          CattiScore(axis: CattiAxis.emotion, value: -2),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.hide, value: 2),
          CattiTraitScore(trait: CattiTrait.observe, value: 2),
          CattiTraitScore(trait: CattiTrait.personalSpace, value: 1),
        ],
      ),
      CattiOption(
        id: 'D',
        text: '끝까지 조용히 숨어 있는 편이에요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -3),
          CattiScore(axis: CattiAxis.curiosity, value: -2),
          CattiScore(axis: CattiAxis.emotion, value: -2),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.hide, value: 3),
          CattiTraitScore(trait: CattiTrait.observe, value: 3),
          CattiTraitScore(trait: CattiTrait.independent, value: 1),
        ],
      ),
      CattiOption(id: 'E', text: '상황에 따라 달라요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q4',
    number: 4,
    category: '사람과의 관계',
    icon: '❤️',
    text: '평소 집사를 따라다니는 편인가요?',
    options: [
      CattiOption(
        id: 'A',
        text: '거의 계속 따라다녀요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 3),
          CattiScore(axis: CattiAxis.emotion, value: 2),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.follow, value: 3),
          CattiTraitScore(trait: CattiTrait.attention, value: 2),
          CattiTraitScore(trait: CattiTrait.approach, value: 1),
        ],
      ),
      CattiOption(
        id: 'B',
        text: '자주 따라다니지만 붙어 있지는 않아요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 2),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.follow, value: 2),
          CattiTraitScore(trait: CattiTrait.personalSpace, value: 1),
          CattiTraitScore(trait: CattiTrait.trust, value: 1),
        ],
      ),
      CattiOption(
        id: 'C',
        text: '필요할 때만 다가와요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -2),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.personalSpace, value: 2),
          CattiTraitScore(trait: CattiTrait.independent, value: 1),
          CattiTraitScore(trait: CattiTrait.observe, value: 1),
        ],
      ),
      CattiOption(
        id: 'D',
        text: '자기만의 공간에 있는 시간이 많아요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -3),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.independent, value: 3),
          CattiTraitScore(trait: CattiTrait.personalSpace, value: 2),
          CattiTraitScore(trait: CattiTrait.calm, value: 1),
        ],
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q5',
    number: 5,
    category: '사람과의 관계',
    icon: '❤️',
    text: '집사와의 교감 방식은?',
    options: [
      CattiOption(
        id: 'A',
        text: '눈을 맞추고 자주 반응해요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 2),
          CattiScore(axis: CattiAxis.emotion, value: 3),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.attention, value: 3),
          CattiTraitScore(trait: CattiTrait.approach, value: 2),
          CattiTraitScore(trait: CattiTrait.talkative, value: 1),
        ],
      ),
      CattiOption(
        id: 'B',
        text: '몸을 기대거나 무릎에 올라와요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 2),
          CattiScore(axis: CattiAxis.emotion, value: 3),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.touch, value: 3),
          CattiTraitScore(trait: CattiTrait.lap, value: 2),
          CattiTraitScore(trait: CattiTrait.trust, value: 2),
        ],
      ),
      CattiOption(
        id: 'C',
        text: '같은 공간에 조용히 있어요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 1),
          CattiScore(axis: CattiAxis.activity, value: -2),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.comfort, value: 3),
          CattiTraitScore(trait: CattiTrait.calm, value: 2),
          CattiTraitScore(trait: CattiTrait.trust, value: 1),
        ],
      ),
      CattiOption(
        id: 'D',
        text: '멀리서 지켜보다가 가끔 다가와요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -2),
          CattiScore(axis: CattiAxis.emotion, value: -2),
        ],
        traits: [
          CattiTraitScore(trait: CattiTrait.observe, value: 3),
          CattiTraitScore(trait: CattiTrait.personalSpace, value: 2),
          CattiTraitScore(trait: CattiTrait.observe, value: 1),
        ],
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  // ------------------------------------------------
  // 세상과의 관계
  // ------------------------------------------------
  CattiQuestion(
    id: 'Q6',
    number: 6,
    category: '세상과의 관계',
    icon: '🔍',
    text: '택배 상자나 종이봉투가 생기면?',
    weight: 1.2,
    options: [
      CattiOption(
        id: 'A',
        text: '바로 들어가 보거나 만져봐요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 3),
          CattiScore(axis: CattiAxis.activity, value: 2),
        ],
        traits: CattiTraitPresets.box,
      ),
      CattiOption(
        id: 'B',
        text: '냄새를 맡고 천천히 확인해요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 2),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: CattiTraitPresets.explorer,
      ),
      CattiOption(
        id: 'C',
        text: '멀리서 지켜보다가 관심을 가져요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: -1),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: [
          ...CattiTraitPresets.shy,
          CattiTraitScore(trait: CattiTrait.hide, value: 1),
        ],
      ),
      CattiOption(
        id: 'D',
        text: '별 관심 없이 지나쳐요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: -3),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: CattiTraitPresets.bread,
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q7',
    number: 7,
    category: '세상과의 관계',
    icon: '🔍',
    text: '닫혀 있던 방문이 열리면?',
    options: [
      CattiOption(
        id: 'A',
        text: '바로 들어가 확인해요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 3),
          CattiScore(axis: CattiAxis.activity, value: 2),
        ],
        traits: CattiTraitPresets.explorer,
      ),
      CattiOption(
        id: 'B',
        text: '문 앞에서 냄새를 맡고 살펴봐요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 2),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: CattiTraitPresets.lion,
      ),
      CattiOption(
        id: 'C',
        text: '멀리서 지켜봐요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: -1),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: CattiTraitPresets.queen,
      ),
      CattiOption(
        id: 'D',
        text: '관심이 거의 없어요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: -3),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: CattiTraitPresets.plant,
      ),
      CattiOption(id: 'E', text: '상황에 따라 달라요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q8',
    number: 8,
    category: '세상과의 관계',
    icon: '🔍',
    text: '집 안에 새로운 물건이 생기면?',
    options: [
      CattiOption(
        id: 'A',
        text: '제일 먼저 확인하러 가요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 3),
          CattiScore(axis: CattiAxis.activity, value: 1),
        ],
        traits: CattiTraitPresets.box,
      ),
      CattiOption(
        id: 'B',
        text: '집사가 쓰는 걸 보고 다가와요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 1),
          CattiScore(axis: CattiAxis.social, value: 1),
        ],
        traits: CattiTraitPresets.cherryBlossom,
      ),
      CattiOption(
        id: 'C',
        text: '한참 뒤에 조심스럽게 확인해요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: -1),
          CattiScore(axis: CattiAxis.emotion, value: -2),
        ],
        traits: [
          ...CattiTraitPresets.shy,
          CattiTraitScore(trait: CattiTrait.hide, value: 1),
        ],
      ),
      CattiOption(
        id: 'D',
        text: '익숙한 물건만 좋아해요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: -3),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: CattiTraitPresets.plant,
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q9',
    number: 9,
    category: '세상과의 관계',
    icon: '🔍',
    text: '높은 곳이나 창가에서는?',
    options: [
      CattiOption(
        id: 'A',
        text: '자주 올라가 주변을 살펴봐요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 2),
          CattiScore(axis: CattiAxis.activity, value: 2),
        ],
        traits: CattiTraitPresets.explorer,
      ),
      CattiOption(
        id: 'B',
        text: '창밖을 오래 바라봐요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 1),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: CattiTraitPresets.lion,
      ),
      CattiOption(
        id: 'C',
        text: '정해진 자리에서만 쉬어요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: -2),
          CattiScore(axis: CattiAxis.activity, value: -2),
        ],
        traits: CattiTraitPresets.bread,
      ),
      CattiOption(
        id: 'D',
        text: '높은 곳은 별로 좋아하지 않아요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: -1),
          CattiScore(axis: CattiAxis.activity, value: -2),
        ],
        traits: CattiTraitPresets.nap,
      ),
      CattiOption(id: 'E', text: '상황에 따라 달라요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q10',
    number: 10,
    category: '세상과의 관계',
    icon: '🔍',
    text: '하루 루틴이나 자리가 바뀌면?',
    options: [
      CattiOption(
        id: 'A',
        text: '금방 적응하고 새롭게 탐색해요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 3),
          CattiScore(axis: CattiAxis.activity, value: 1),
        ],
        traits: CattiTraitPresets.explorer,
      ),
      CattiOption(
        id: 'B',
        text: '처음엔 낯설지만 곧 적응해요.',
        scores: [CattiScore(axis: CattiAxis.curiosity, value: 1)],
        traits: CattiTraitPresets.cherryBlossom,
      ),
      CattiOption(
        id: 'C',
        text: '조금 불편해하고 원래 자리를 찾아요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: -2),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: CattiTraitPresets.plant,
      ),
      CattiOption(
        id: 'D',
        text: '변화가 크면 스트레스를 받아요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: -3),
          CattiScore(axis: CattiAxis.emotion, value: -2),
        ],
        traits: CattiTraitPresets.cactus,
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  // ------------------------------------------------
  // 활동과 놀이
  // ------------------------------------------------
  CattiQuestion(
    id: 'Q11',
    number: 11,
    category: '활동과 놀이',
    icon: '⚡',
    text: '밤이나 새벽에는?',
    options: [
      CattiOption(
        id: 'A',
        text: '갑자기 우다다를 시작해요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: 3),
          CattiScore(axis: CattiAxis.curiosity, value: 1),
        ],
        traits: CattiTraitPresets.zoomies,
      ),
      CattiOption(
        id: 'B',
        text: '조용히 돌아다니거나 창밖을 봐요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: 1),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: CattiTraitPresets.moon,
      ),
      CattiOption(
        id: 'C',
        text: '집사 곁에서 쉬거나 자요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: -2),
          CattiScore(axis: CattiAxis.emotion, value: 1),
        ],
        traits: CattiTraitPresets.cloud,
      ),
      CattiOption(
        id: 'D',
        text: '거의 계속 자요.',
        scores: [CattiScore(axis: CattiAxis.activity, value: -3)],
        traits: CattiTraitPresets.nap,
      ),
      CattiOption(id: 'E', text: '상황에 따라 달라요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q12',
    number: 12,
    category: '활동과 놀이',
    icon: '⚡',
    text: '낚싯대나 깃털 장난감을 보면?',
    weight: 1.3,
    options: [
      CattiOption(
        id: 'A',
        text: '바로 달려들고 끝까지 집중해요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: 3),
          CattiScore(axis: CattiAxis.curiosity, value: 2),
        ],
        traits: CattiTraitPresets.feather,
      ),
      CattiOption(
        id: 'B',
        text: '신나게 놀다가 쉬어요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: 2),
          CattiScore(axis: CattiAxis.emotion, value: 1),
        ],
        traits: CattiTraitPresets.zoomies,
      ),
      CattiOption(
        id: 'C',
        text: '잠깐 관심을 보이고 금방 쉬어요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: -1),
          CattiScore(axis: CattiAxis.curiosity, value: -1),
        ],
        traits: CattiTraitPresets.cloud,
      ),
      CattiOption(
        id: 'D',
        text: '거의 관심이 없어요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: -3),
          CattiScore(axis: CattiAxis.curiosity, value: -1),
        ],
        traits: CattiTraitPresets.nap,
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q13',
    number: 13,
    category: '활동과 놀이',
    icon: '⚡',
    text: '집 안에서 에너지가 올라오면?',
    options: [
      CattiOption(
        id: 'A',
        text: '전력질주하거나 점프해요.',
        scores: [CattiScore(axis: CattiAxis.activity, value: 3)],
        traits: CattiTraitPresets.zoomies,
      ),
      CattiOption(
        id: 'B',
        text: '여기저기 돌아다니며 확인해요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: 2),
          CattiScore(axis: CattiAxis.curiosity, value: 2),
        ],
        traits: CattiTraitPresets.explorer,
      ),
      CattiOption(
        id: 'C',
        text: '장난감이나 집사에게 관심을 보여요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: 1),
          CattiScore(axis: CattiAxis.social, value: 1),
          CattiScore(axis: CattiAxis.emotion, value: 1),
        ],
        traits: CattiTraitPresets.ribbon,
      ),
      CattiOption(
        id: 'D',
        text: '에너지가 크게 오르는 편은 아니에요.',
        scores: [CattiScore(axis: CattiAxis.activity, value: -3)],
        traits: CattiTraitPresets.bread,
      ),
      CattiOption(id: 'E', text: '상황에 따라 달라요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q14',
    number: 14,
    category: '활동과 놀이',
    icon: '⚡',
    text: '하루 대부분의 모습은?',
    options: [
      CattiOption(
        id: 'A',
        text: '뛰거나 놀거나 돌아다녀요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: 3),
          CattiScore(axis: CattiAxis.curiosity, value: 1),
        ],
        traits: CattiTraitPresets.zoomies,
      ),
      CattiOption(
        id: 'B',
        text: '창밖을 보거나 집 안을 살펴봐요.',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 2),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: CattiTraitPresets.lion,
      ),
      CattiOption(
        id: 'C',
        text: '조용히 쉬거나 같은 공간에 있어요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: -2),
          CattiScore(axis: CattiAxis.social, value: 1),
        ],
        traits: CattiTraitPresets.cloud,
      ),
      CattiOption(
        id: 'D',
        text: '잠을 자거나 한 자리에서 오래 쉬어요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: -3),
          CattiScore(axis: CattiAxis.curiosity, value: -1),
        ],
        traits: CattiTraitPresets.nap,
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q15',
    number: 15,
    category: '활동과 놀이',
    icon: '⚡',
    text: '놀이가 끝나면?',
    options: [
      CattiOption(
        id: 'A',
        text: '더 하자고 요구해요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: 3),
          CattiScore(axis: CattiAxis.emotion, value: 1),
        ],
        traits: CattiTraitPresets.feather,
      ),
      CattiOption(
        id: 'B',
        text: '만족하고 집사 곁에서 쉬어요.',
        scores: [
          CattiScore(axis: CattiAxis.emotion, value: 2),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: CattiTraitPresets.kneading,
      ),
      CattiOption(
        id: 'C',
        text: '혼자 쉬러 가요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -1),
          CattiScore(axis: CattiAxis.activity, value: -2),
        ],
        traits: CattiTraitPresets.cactus,
      ),
      CattiOption(
        id: 'D',
        text: '처음부터 오래 놀지 않아요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: -3),
          CattiScore(axis: CattiAxis.curiosity, value: -1),
        ],
        traits: CattiTraitPresets.nap,
      ),
      CattiOption(id: 'E', text: '상황에 따라 달라요.', scores: [], traits: []),
    ],
  ),

  // ------------------------------------------------
  // 애정 표현
  // ------------------------------------------------
  CattiQuestion(
    id: 'Q16',
    number: 16,
    category: '애정 표현',
    icon: '💕',
    text: '골골송은?',
    options: [
      CattiOption(
        id: 'A',
        text: '자주 들려줘요.',
        scores: [
          CattiScore(axis: CattiAxis.emotion, value: 3),
          CattiScore(axis: CattiAxis.social, value: 1),
        ],
        traits: CattiTraitPresets.kneading,
      ),
      CattiOption(
        id: 'B',
        text: '기분 좋을 때 들려줘요.',
        scores: [CattiScore(axis: CattiAxis.emotion, value: 2)],
        traits: CattiTraitPresets.cherryBlossom,
      ),
      CattiOption(
        id: 'C',
        text: '가끔 아주 조용히 해요.',
        scores: [CattiScore(axis: CattiAxis.emotion, value: 1)],
        traits: CattiTraitPresets.shy,
      ),
      CattiOption(
        id: 'D',
        text: '거의 들어본 적 없어요.',
        scores: [CattiScore(axis: CattiAxis.emotion, value: -3)],
        traits: CattiTraitPresets.cactus,
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q17',
    number: 17,
    category: '애정 표현',
    icon: '💕',
    text: '꾹꾹이는?',
    options: [
      CattiOption(
        id: 'A',
        text: '자주 해요.',
        scores: [
          CattiScore(axis: CattiAxis.emotion, value: 3),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: CattiTraitPresets.kneading,
      ),
      CattiOption(
        id: 'B',
        text: '가끔 해요.',
        scores: [CattiScore(axis: CattiAxis.emotion, value: 2)],
        traits: CattiTraitPresets.cherryBlossom,
      ),
      CattiOption(
        id: 'C',
        text: '거의 안 하지만 곁에는 있어요.',
        scores: [
          CattiScore(axis: CattiAxis.emotion, value: -1),
          CattiScore(axis: CattiAxis.social, value: 1),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: CattiTraitPresets.shy,
      ),
      CattiOption(
        id: 'D',
        text: '거의 하지 않고 혼자 있는 걸 좋아해요.',
        scores: [
          CattiScore(axis: CattiAxis.emotion, value: -3),
          CattiScore(axis: CattiAxis.social, value: -1),
        ],
        traits: CattiTraitPresets.cactus,
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q18',
    number: 18,
    category: '애정 표현',
    icon: '💕',
    text: '배를 보이거나 몸을 맡기는 행동은?',
    weight: 1.2,
    options: [
      CattiOption(
        id: 'A',
        text: '자주 보여주고 만져도 괜찮아요.',
        scores: [
          CattiScore(axis: CattiAxis.emotion, value: 3),
          CattiScore(axis: CattiAxis.social, value: 1),
        ],
        traits: CattiTraitPresets.ribbon,
      ),
      CattiOption(
        id: 'B',
        text: '기분 좋을 때만 허락해요.',
        scores: [CattiScore(axis: CattiAxis.emotion, value: 1)],
        traits: CattiTraitPresets.queen,
      ),
      CattiOption(
        id: 'C',
        text: '보이긴 하지만 만지는 건 싫어해요.',
        scores: [CattiScore(axis: CattiAxis.emotion, value: -2)],
        traits: CattiTraitPresets.cactus,
      ),
      CattiOption(
        id: 'D',
        text: '거의 보여주지 않아요.',
        scores: [
          CattiScore(axis: CattiAxis.emotion, value: -3),
          CattiScore(axis: CattiAxis.social, value: -1),
        ],
        traits: CattiTraitPresets.shy,
      ),
      CattiOption(id: 'E', text: '상황에 따라 달라요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q19',
    number: 19,
    category: '애정 표현',
    icon: '💕',
    text: '집사가 힘들거나 아플 때는?',
    options: [
      CattiOption(
        id: 'A',
        text: '가까이 와서 몸을 기대요.',
        scores: [
          CattiScore(axis: CattiAxis.emotion, value: 3),
          CattiScore(axis: CattiAxis.social, value: 2),
        ],
        traits: CattiTraitPresets.kneading,
      ),
      CattiOption(
        id: 'B',
        text: '근처에 조용히 머물러요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 1),
          CattiScore(axis: CattiAxis.emotion, value: -1),
          CattiScore(axis: CattiAxis.activity, value: -1),
        ],
        traits: CattiTraitPresets.cloud,
      ),
      CattiOption(
        id: 'C',
        text: '멀리서 바라보다가 가끔 다가와요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: -1),
          CattiScore(axis: CattiAxis.emotion, value: -2),
        ],
        traits: [
          ...CattiTraitPresets.shy,
          CattiTraitScore(trait: CattiTrait.hide, value: 1),
        ],
      ),
      CattiOption(
        id: 'D',
        text: '평소와 크게 다르지 않아요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: -1),
          CattiScore(axis: CattiAxis.curiosity, value: -1),
        ],
        traits: CattiTraitPresets.plant,
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q20',
    number: 20,
    category: '애정 표현',
    icon: '💕',
    text: '우리 아이의 사랑 표현에 가장 가까운 것은?',
    weight: 1.4,
    options: [
      CattiOption(
        id: 'A',
        text: '먼저 다가와 마음을 표현해요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 2),
          CattiScore(axis: CattiAxis.emotion, value: 3),
        ],
        traits: CattiTraitPresets.kneading,
      ),
      CattiOption(
        id: 'B',
        text: '귀여운 행동으로 집사를 웃게 해요.',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 2),
          CattiScore(axis: CattiAxis.emotion, value: 2),
          CattiScore(axis: CattiAxis.activity, value: 1),
        ],
        traits: CattiTraitPresets.ribbon,
      ),
      CattiOption(
        id: 'C',
        text: '함께 놀거나 움직이며 표현해요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: 3),
          CattiScore(axis: CattiAxis.curiosity, value: 1),
        ],
        traits: CattiTraitPresets.feather,
      ),
      CattiOption(
        id: 'D',
        text: '조용히 같은 공간에 머물러요.',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: -2),
          CattiScore(axis: CattiAxis.emotion, value: -1),
        ],
        traits: [
          ...CattiTraitPresets.shy,
          CattiTraitScore(trait: CattiTrait.hide, value: 1),
        ],
      ),
      CattiOption(id: 'E', text: '아직 잘 모르겠어요.', scores: [], traits: []),
    ],
  ),

  CattiQuestion(
    id: 'Q21',
    number: 21,
    category: '마지막 질문',
    icon: '🐾',
    text: '우리 아이를 떠올리면 가장 먼저 생각나는 모습은?',
    weight: 0.5,
    options: [
      CattiOption(
        id: 'A',
        text: '햇살 아래 편안히 쉬는 모습',
        scores: [
          CattiScore(axis: CattiAxis.activity, value: -1),
          CattiScore(axis: CattiAxis.curiosity, value: -1),
        ],
        traits: CattiTraitPresets.cloud,
        tieBreakerType: 'relax',
      ),
      CattiOption(
        id: 'B',
        text: '신나게 뛰노는 모습',
        scores: [CattiScore(axis: CattiAxis.activity, value: 1)],
        traits: CattiTraitPresets.zoomies,
        tieBreakerType: 'play',
      ),
      CattiOption(
        id: 'C',
        text: '집사를 바라보는 모습',
        scores: [
          CattiScore(axis: CattiAxis.social, value: 1),
          CattiScore(axis: CattiAxis.emotion, value: 1),
        ],
        traits: CattiTraitPresets.cherryBlossom,
        tieBreakerType: 'together',
      ),
      CattiOption(
        id: 'D',
        text: '새로운 곳을 탐험하는 모습',
        scores: [
          CattiScore(axis: CattiAxis.curiosity, value: 1),
          CattiScore(axis: CattiAxis.activity, value: 1),
        ],
        traits: CattiTraitPresets.explorer,
        tieBreakerType: 'explore',
      ),
      CattiOption(
        id: 'E',
        text: '아직 잘 모르겠어요.',
        scores: [],
        traits: [],
        tieBreakerType: 'unknown',
      ),
    ],
  ),
];
