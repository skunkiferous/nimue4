# Copyright 2016 Xored Software, Inc.

# called when we finish playing audio, either because it played to completion or because a Stop() call turned it off early
declareBuiltinDelegate(FOnAudioFinished, dkDynamicMulticast, "Components/AudioComponent.h")

# shadow delegate declaration for above
declareBuiltinDelegate(FOnAudioFinishedNative, dkMulticast, "Components/AudioComponent.h", comp: ptr UAudioComponent)

# Called when subtitles are sent to the SubtitleManager.  Set this delegate if you want to hijack the subtitles for other purposes
declareBuiltinDelegate(FOnQueueSubtitles, dkDynamic, "Components/AudioComponent.h", subtitles: TArray[FSubtitleCue], cueDuration: float32)

wclass(FAudioComponentParam, header: "Components/AudioComponent.h", bycopy):
  ##	Struct used for storing one per-instance named parameter for this AudioComponent.
  ##	Certain nodes in the SoundCue may reference parameters by name so they can be adjusted per-instance.
  var paramName: FName
    ## Name of the parameter
  var floatParam: float32
    ## Value of the parameter when used as a float
  var boolParam: bool
    ## Value of the parameter when used as a boolean
  var intParam: int32
    ## Value of the parameter when used as an integer
  var soundWaveParam: ptr USoundWave
    ## Value of the parameter when used as a sound wave

  proc initFAudioComponentParam(name: FName): FAudioComponentParam {.constructor.}
  proc initFAudioComponentParam(): FAudioComponentParam {.constructor.}

wclass(UAudioComponent of USceneComponent, header: "Components/AudioComponent.h", notypedef):
  ## AudioComponent is used to play a Sound

  var sound: ptr USoundBase
    ## The sound to be played
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Sound)

  var instanceParameters: TArray[FAudioComponentParam]
    ## Array of per-instance parameters for this AudioComponent.
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Sound, AdvancedDisplay)

  var soundClassOverride: ptr USoundClass
    ## Optional sound group this AudioComponent belongs to
    ## UPROPERTY(EditAnywhere, Category=Sound, AdvancedDisplay)

  var bAutoDestroy: bool
    ## Auto destroy this component on completion
    ## UPROPERTY()

  var bStopWhenOwnerDestroyed: bool
    ## Stop sound when owner is destroyed
    ## UPROPERTY()

  var bShouldRemainActiveIfDropped: bool
    ## Whether the wave instances should remain active if they're dropped by the prioritization code. Useful for e.g. vehicle sounds that shouldn't cut out.
    ## UPROPERTY()

  var bAllowSpatialization: bool
    ## Is this audio component allowed to be spatialized?
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Attenuation)

  var bOverrideAttenuation: bool
    ## Should the Attenuation Settings asset be used (false) or should the properties set directly on the component be used for attenuation properties
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Attenuation)

  var bIsUISound: bool
    ## Whether or not this sound plays when the game is paused in the UI
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Sound)

  var bEnableLowPassFilter: bool
    ## Whether or not to apply a low-pass filter to the sound that plays in this audio component.
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Filter)

  var bOverridePriority: bool
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Sound)

  var pitchModulationMin: cfloat
    ## The lower bound to use when randomly determining a pitch multiplier
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Modulation)

  var pitchModulationMax: cfloat
    ## The upper bound to use when randomly determining a pitch multiplier
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Modulation)

  var volumeModulationMin: cfloat
    ## The lower bound to use when randomly determining a volume multiplier
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Modulation)

  var volumeModulationMax: cfloat
    ## The upper bound to use when randomly determining a volume multiplier
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Modulation)

  var volumeMultiplier: cfloat
    ## A volume multiplier to apply to sounds generated by this component
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Sound)

  var priority: cfloat
    ## A priority value that is used for sounds that play on this component that scales against final output volume.
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Sound, meta = (ClampMin = "0.0", UIMin = "0.0", EditCondition = "bOverridePriority"))

  var pitchMultiplier: cfloat
    ## A pitch multiplier to apply to sounds generated by this component
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Sound)

  var lowPassFilterFrequency: cfloat
    ## The frequency of the lowpass filter (in hertz) to apply to this voice. A frequency of 0.0 is the device sample rate and will bypass the filter.
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Filter, meta = (ClampMin = "0.0", UIMin = "0.0", EditCondition = "bEnableLowPassFilter"))

  var attenuationSettings: ptr USoundAttenuation
    ## The frequency of the lowpass filter (in hertz) to apply to this voice. A frequency of 0.0 is the device sample rate and will bypass the filter.
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Filter, meta = (ClampMin = "0.0", UIMin = "0.0", EditCondition = "bEnableLowPassFilter"))

  var attenuationOverrides: FAttenuationSettings
    ## If bOverrideSettings is true, the attenuation properties to use for sounds generated by this component
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Attenuation, meta=(EditCondition="bOverrideAttenuation"))

  var concurrencySettings: ptr USoundConcurrency
    ## What sound concurrency to use for sounds generated by this audio component
    ## UPROPERTY(EditAnywhere, BlueprintReadWrite, Category=Concurrency)

  var occlusionCheckInterval: cfloat
    ## while playing, this component will check for occlusion from its closest listener every this many seconds

  var onAudioFinished: FOnAudioFinished
    ## called when we finish playing audio, either because it played to completion or because a Stop() call turned it off early
    ## UPROPERTY(BlueprintAssignable)

  var onAudioFinishedNative: FOnAudioFinishedNative
    ## shadow delegate for non UObject subscribers

  var onQueueSubtitles: FOnQueueSubtitles
    ## Called when subtitles are sent to the SubtitleManager.  Set this delegate if you want to hijack the subtitles for other purposes
    ## UPROPERTY()

  proc setSound(newSound: ptr USoundBase)
    ## Set what sound is played by this component
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc fadeIn(fadeInDuration: cfloat; fadeVolumeLevel: cfloat = 1.0;
              startTime: cfloat = 0.0)
    ## This can be used in place of "play" when it is desired to fade in the sound over time.
    ##
    ## If FadeTime is 0.0, the change in volume is instant.
    ## If FadeTime is > 0.0, the multiplier will be increased from 0 to FadeVolumeLevel over FadeIn seconds.
    ##
    ## @param FadeInDuration how long it should take to reach the FadeVolumeLevel
    ## @param FadeVolumeLevel the percentage of the AudioComponents's calculated volume to fade to
    ##
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc fadeOut(fadeOutDuration: cfloat; fadeVolumeLevel: cfloat)
    ## This is used in place of "stop" when it is desired to fade the volume of the sound before stopping.
    ##
    ## If FadeTime is 0.0, this is the same as calling Stop().
    ## If FadeTime is > 0.0, this will adjust the volume multiplier to FadeVolumeLevel over FadeInTime seconds
    ## and then stop the sound.
    ##
    ## @param FadeOutDuration how long it should take to reach the FadeVolumeLevel
    ## @param FadeVolumeLevel the percentage of the AudioComponents's calculated volume in which to fade to
    ##
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc play(startTime: cfloat = 0.0)
    ## Start a sound playing on an audio component
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc stop()
    ## Stop an audio component playing its sound cue, issue any delegates if needed
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc isPlaying(): bool {.noSideEffect.}
    ## @return true if this component is currently playing a SoundCue.
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc adjustVolume(adjustVolumeDuration: cfloat; adjustVolumeLevel: cfloat)
    ## This will allow one to adjust the volume of an AudioComponent on the fly
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc setFloatParameter(inName: FName; inFloat: cfloat)
    ##  Set a float instance parameter for use in sound cues played by this audio component
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc setWaveParameter(inName: FName; inWave: ptr USoundWave)
    ##  Set a sound wave instance parameter for use in sound cues played by this audio component
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc setBoolParameter(inName: FName; inBool: bool)
    ## Set a boolean instance parameter for use in sound cues played by this audio component
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio", meta=(DisplayName="Set Boolean Parameter"))

  proc setIntParameter(inName: FName; inInt: int32)
    ## Set an integer instance parameter for use in sound cues played by this audio component
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio", meta=(DisplayName="Set Integer Parameter"))

  proc setVolumeMultiplier(newVolumeMultiplier: cfloat)
    ## Set a new volume multiplier
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc setPitchMultiplier(newPitchMultiplier: cfloat)
    ## Set a new pitch multiplier
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc setUISound(bInUISound: bool)
    ## Set whether sounds generated by this audio component should be considered UI sounds
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc adjustAttenuation(inAttenuationSettings: FAttenuationSettings)
    ## Modify the attenuation settings of the audio component
    ## UFUNCTION(BlueprintCallable, Category="Audio|Components|Audio")

  proc playbackCompleted(bFailedToStart: bool)
    ## Called by the ActiveSound to inform the component that playback is finished

  proc setSoundParameter(param: FAudioComponentParam)
    ## Sets the sound instance parameter.

# public:
  var bSuppressSubtitles: bool
    ## If true, subtitles in the sound data will be ignored.

  var bPreviewComponent: bool
    ## Whether this audio component is previewing a sound

  var bIgnoreForFlushing: bool
    ## If true, this sound will not be stopped when flushing the audio device.

  var bEQFilterApplied: bool
    ## Whether audio effects are applied

  var bAlwaysPlay: bool
    ## Whether to artificially prioritize the component to play

  var bIsMusic: bool
    ## Whether or not this audio component is a music clip

  var bReverb: bool
    ## Whether or not the audio component should be excluded from reverb EQ processing

  var bCenterChannelOnly: bool
    ## Whether or not this sound class forces sounds to the center channel

  var subtitlePriority: cfloat
    ## Used by the subtitle manager to prioritize subtitles wave instances spawned by this component.

  proc getAttenuationSettingsToApply(): ptr FAttenuationSettings {.noSideEffect.}
    ## Returns a pointer to the attenuation settings to be used (if any) for this audio component dependent on the SoundAttenuation asset or overrides set.

  proc BP_GetAttenuationSettingsToApply(outAttenuationSettings: var FAttenuationSettings): bool
    ## UFUNCTION(BlueprintCallable, Category = "Audio|Components|Audio", meta = (DisplayName = "Get Attenuation Settings To Apply"))

  # proc collectAttenuationShapesForVisualization(
  #     shapeDetailsMap: var TMultiMap[EAttenuationShape, AttenuationShapeDetails]) {.noSideEffect.}
  #   ## Collects the various attenuation shapes that may be applied to the sound played by the audio component for visualization in the editor or via the in game debug visualization.

  proc getAudioDevice(): ptr FAudioDevice {.noSideEffect.}
    ## Returns the active audio device to use for this component based on whether or not the component is playing in a world.
