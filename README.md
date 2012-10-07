#About
標準でqにマップされている、いわゆるマクロ機能、Recordingを、名前を付けて保存し、
Uniteインターフェイスで好きな時に呼び出すプラグインである。


#Variables
`g:unite_source_recording_char`は'z'にセットされている。
これはレジスタ'z'をRecording用のレジスタとして使うという意味である。
これが都合が悪いのなら、別のレジスタを使うようにすること。

`g:unite_source_recording_directory`はunite-recordingがログファイルを作成する
ディレクトリである。
デフォルトで`g:unite_data_directory`と同じディレクトリが使われる。


#Interface
- :Unite recording
  Recordingを一覧する。default action は set である。
  これは Recording用のレジスタに該当Recordingをセットする。

- :UniteRecordingBegin
  新しくRecordingを登録する。
  初めにdescriptionの入力が求められ、次にRecordingが開始される。
  descriptionはRecordingの名前として機能する。

- <Plug>(unite-recording-execute)
  Recording用のレジスタを再生する。
