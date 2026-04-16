import 'dart:math';

import 'package:flutter/material.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final Random _random = Random();

  late _WordScramblePuzzle _scramblePuzzle;
  late _VocabQuestion _vocabQuestion;
  late _SentenceChallenge _sentenceChallenge;

  int _scrambleStreak = 0;
  int _vocabScore = 0;
  int _sentenceScore = 0;

  final TextEditingController _scrambleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scramblePuzzle = _nextScramblePuzzle();
    _vocabQuestion = _nextVocabQuestion();
    _sentenceChallenge = _nextSentenceChallenge();
  }

  @override
  void dispose() {
    _scrambleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F3EA), Color(0xFFF3E4CF)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 28),
          children: [
            _buildHero(),
            const SizedBox(height: 16),
            _buildSectionTitle(
              title: 'Word Scramble',
              subtitle:
                  'Unscramble useful English words from real-world usage.',
            ),
            const SizedBox(height: 10),
            _buildScrambleCard(),
            const SizedBox(height: 18),
            _buildSectionTitle(
              title: 'Meaning Match',
              subtitle: 'Pick the closest meaning to grow vocabulary offline.',
            ),
            const SizedBox(height: 10),
            _buildVocabCard(),
            const SizedBox(height: 18),
            _buildSectionTitle(
              title: 'Sentence Builder',
              subtitle:
                  'Choose the best sentence to sound more natural in English.',
            ),
            const SizedBox(height: 10),
            _buildSentenceCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBF5), Color(0xFFF2E2CA)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE4CEB2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB22D1F), Color(0xFF7C1714)],
              ),
            ),
            child: const Icon(
              Icons.extension_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline English Games',
                  style: TextStyle(
                    color: Color(0xFF4A2017),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Practice vocabulary, spelling, and sentence sense without internet.',
                  style: TextStyle(
                    color: Color(0xFF7A6247),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF3B2417),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7A6247),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildScrambleCard() {
    return _GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ScorePill(label: 'Streak', value: '$_scrambleStreak'),
              const Spacer(),
              TextButton(
                onPressed: _resetScramble,
                child: const Text('New word'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _scramblePuzzle.hint,
            style: const TextStyle(
              color: Color(0xFF7A6247),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final scrambledLetters = (_scramblePuzzle.scrambled ?? '').split(
                '',
              );
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: scrambledLetters
                    .map(
                      (letter) => Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFF7EA), Color(0xFFF3DFC2)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE3CCAC)),
                        ),
                        child: Text(
                          letter.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF6D1715),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _scrambleController,
            decoration: InputDecoration(
              hintText: 'Type your answer',
              filled: true,
              fillColor: const Color(0xFFFFFBF5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE4CEB2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE4CEB2)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _submitScramble,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8C1D18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Check Answer'),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabCard() {
    return _GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ScorePill(label: 'Score', value: '$_vocabScore'),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    setState(() => _vocabQuestion = _nextVocabQuestion()),
                child: const Text('Skip'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Which option is closest in meaning to "${_vocabQuestion.word}"?',
            style: const TextStyle(
              color: Color(0xFF3B2417),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ..._vocabQuestion.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: () => _submitVocab(option),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  side: const BorderSide(color: Color(0xFFE3CCAC)),
                  backgroundColor: const Color(0xFFFFFBF5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Color(0xFF4A2017),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceCard() {
    return _GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ScorePill(label: 'Correct', value: '$_sentenceScore'),
              const Spacer(),
              TextButton(
                onPressed: () => setState(
                  () => _sentenceChallenge = _nextSentenceChallenge(),
                ),
                child: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _sentenceChallenge.prompt,
            style: const TextStyle(
              color: Color(0xFF3B2417),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ..._sentenceChallenge.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _submitSentence(option),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFBF5), Color(0xFFF5E7D1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE3CCAC)),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Color(0xFF4A2017),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetScramble() {
    setState(() {
      _scramblePuzzle = _nextScramblePuzzle();
      _scrambleController.clear();
    });
  }

  void _submitScramble() {
    final answer = _scrambleController.text.trim().toLowerCase();
    if (answer == _scramblePuzzle.answer.toLowerCase()) {
      setState(() {
        _scrambleStreak++;
        _scramblePuzzle = _nextScramblePuzzle();
        _scrambleController.clear();
      });
      _showFeedback('Correct! Great spelling.', isSuccess: true);
    } else {
      setState(() => _scrambleStreak = 0);
      _showFeedback(
        'Try again. Hint: ${_scramblePuzzle.hint}',
        isSuccess: false,
      );
    }
  }

  void _submitVocab(String option) {
    final correct = option == _vocabQuestion.answer;
    if (correct) {
      setState(() => _vocabScore++);
      _showFeedback('Nice. "$option" is the closest meaning.', isSuccess: true);
    } else {
      _showFeedback(
        'Not quite. Correct answer: ${_vocabQuestion.answer}',
        isSuccess: false,
      );
    }
    setState(() => _vocabQuestion = _nextVocabQuestion());
  }

  void _submitSentence(String option) {
    final correct = option == _sentenceChallenge.answer;
    if (correct) {
      setState(() => _sentenceScore++);
      _showFeedback('Correct. That sounds more natural.', isSuccess: true);
    } else {
      _showFeedback(
        'Better choice: ${_sentenceChallenge.answer}',
        isSuccess: false,
      );
    }
    setState(() => _sentenceChallenge = _nextSentenceChallenge());
  }

  void _showFeedback(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? const Color(0xFF2F6C52)
            : const Color(0xFF8C1D18),
      ),
    );
  }

  _WordScramblePuzzle _nextScramblePuzzle() {
    const puzzles = [
      _WordScramblePuzzle(
        answer: 'editorial',
        hint: 'A newspaper opinion piece',
      ),
      _WordScramblePuzzle(
        answer: 'headlines',
        hint: 'Big important news titles',
      ),
      _WordScramblePuzzle(
        answer: 'vocabulary',
        hint: 'A set of words you know',
      ),
      _WordScramblePuzzle(
        answer: 'grammar',
        hint: 'Rules for correct language',
      ),
      _WordScramblePuzzle(
        answer: 'journalist',
        hint: 'A person who reports news',
      ),
    ];
    final selected = puzzles[_random.nextInt(puzzles.length)];
    return selected.scrambledVariant(_random);
  }

  _VocabQuestion _nextVocabQuestion() {
    const questions = [
      _VocabQuestion(
        word: 'accurate',
        answer: 'correct',
        options: ['correct', 'angry', 'silent', 'late'],
      ),
      _VocabQuestion(
        word: 'brief',
        answer: 'short',
        options: ['careful', 'short', 'bright', 'costly'],
      ),
      _VocabQuestion(
        word: 'improve',
        answer: 'make better',
        options: ['make smaller', 'make better', 'make older', 'make slower'],
      ),
      _VocabQuestion(
        word: 'confident',
        answer: 'self-assured',
        options: ['self-assured', 'sleepy', 'confused', 'distant'],
      ),
    ];
    return questions[_random.nextInt(questions.length)];
  }

  _SentenceChallenge _nextSentenceChallenge() {
    const challenges = [
      _SentenceChallenge(
        prompt: 'Choose the more natural English sentence.',
        answer: 'I have been reading the article since morning.',
        options: [
          'I am reading the article since morning.',
          'I have been reading the article since morning.',
          'I reading the article from morning.',
        ],
      ),
      _SentenceChallenge(
        prompt: 'Pick the best sentence for polite everyday English.',
        answer: 'Could you please help me with this word?',
        options: [
          'Help me with this word.',
          'Could you please help me with this word?',
          'You help this word now.',
        ],
      ),
      _SentenceChallenge(
        prompt: 'Which sentence sounds clearer in standard English?',
        answer: 'She explained the news clearly to everyone.',
        options: [
          'She explained clearly the news to everyone.',
          'She explained the news clearly to everyone.',
          'She clear explained everyone the news.',
        ],
      ),
    ];
    return challenges[_random.nextInt(challenges.length)];
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7EA), Color(0xFFF3DFC2)],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3CCAC)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Color(0xFF6D1715),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _WordScramblePuzzle {
  const _WordScramblePuzzle({
    required this.answer,
    required this.hint,
    this.scrambled,
  });

  final String answer;
  final String hint;
  final String? scrambled;

  _WordScramblePuzzle scrambledVariant(Random random) {
    final chars = answer.split('');
    chars.shuffle(random);
    var candidate = chars.join();
    if (candidate.toLowerCase() == answer.toLowerCase()) {
      chars.shuffle(random);
      candidate = chars.join();
    }
    return _WordScramblePuzzle(
      answer: answer,
      hint: hint,
      scrambled: candidate,
    );
  }
}

class _VocabQuestion {
  const _VocabQuestion({
    required this.word,
    required this.answer,
    required this.options,
  });

  final String word;
  final String answer;
  final List<String> options;
}

class _SentenceChallenge {
  const _SentenceChallenge({
    required this.prompt,
    required this.answer,
    required this.options,
  });

  final String prompt;
  final String answer;
  final List<String> options;
}
