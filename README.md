##About
標準で q にマップされている、いわゆるマクロ機能、 Recording を、名前を付けて保存し、  
Uniteインターフェイスで好きな時に呼び出すプラグインである。


##Variables
- `g:unite_source_recording_char`は 'z' にセットされている。  
これはレジスタ 'z' を Recording 用のレジスタとして使うという意味である。  
これが都合が悪いのなら、別のレジスタを使うようにすること。

- `g:unite_source_recording_directory`は unite-recording がログファイルを作成する  
ディレクトリである。  
デフォルトで`g:unite_data_directory`と同じディレクトリが使われる。


##Interface
- `:Unite recording`  
  Recordingを一覧する。default action は set である。  
  これは Recording用のレジスタに該当Recordingをセットする。

- `:UniteRecordingBegin`  
  新しく Recording を登録する。  
  初めに description の入力が求められ、次に Recording が開始される。  
  description は Recording の名前として機能する。

- `<Plug>(unite-recording-execute)`  
  Recording 用のレジスタを再生する。
