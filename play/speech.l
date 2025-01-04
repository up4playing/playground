interface SpeechSynthesisVoice
	bool default // Indicates whether the voice is the default voice for the current app language
	string lang // Returns a BCP 47 language tag indicating the language of the voice.
	bool localService // Indicates if its local speech synthesizer service (true) or a remote service (false)
	string name // Returns a human-readable name that represents the voice.
	string voiceURI // Returns the type of URI and location of the speech synthesis service for this voice.
	
transient speech
	int voiceIndex
	SpeechSynthesisVoice[] voices
	SpeechSynthesisVoice voice
	float rate = 1
	
	private inline js SpeechSynthesisVoice[] getVoices() speechSynthesis.getVoices()
		
	nextVoice
		voice = voices[voiceIndex incrementAndWrap voices.length]
		
	js void setup: string language, string[] voicePreferences = ["Google", "Paulina", "Mónica"], float rate = 1
		var msg = new SpeechSynthesisUtterance();
		speechSynthesis.addEventListener("voiceschanged", () => speech.setupVoice(language, voicePreferences));
		speech.setupVoice(language, voicePreferences);
		speech.rate = rate;
	
	private setupVoice: string language, string[] voicePreferences
		voices = getVoices.where.lang?.startsWith(language)
		for voicePreferences as preference
			voiceIndex = voices.indexWhere.name.contains(preference)
			if voiceIndex != -1
				voice = voices[voiceIndex]
				return
		voice = voices.first
		
	js void say: string value
		if(core.isPremiere && input.isCertain) {
			speechSynthesis.cancel();
			const utterance = new SpeechSynthesisUtterance(value);
			utterance.voice = speech.voice;
			utterance.rate = speech.rate;
			speechSynthesis.speak(utterance);
		}