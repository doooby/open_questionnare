class DummyQuestionnaire < Questionnaire






end

# Basically initialization - on class (re)loaded
DummyQuestionnaire.current_version_rank = 0
DummyQuestionnaire::V0
