#--*-coding:utf-8-*--

class Satasupe < DiceBot
  
  def initialize
    super
    @sendMode = 2;
    @sortType = 1;
    @d66Type = 2;
  end
  
  def gameType
    "Satasupe"
  end
  
  def getHelpMessage
    return <<MESSAGETEXT
・サタスペ　判定ロール  　(nR>=x[y,z]) (n:最大ロール数, x:目標値, y:目標成功数, z:ファンブル値)
・タグ決定表　　　　　　　(TAGT)
・情報イベント表　　　　　(箸ｷIET)
　　犯罪表(CrimeIET)、生活表(LifeIET)、恋愛表(LoveIET)、教養表(CultureIET)、戦闘表(CombatIET)
・情報ハプニング表　　　　(箸ｷIHT)
　　犯罪表(CrimeIHT)、生活表(LifeIHT)、恋愛表(LoveIHT)、教養表(CultureIHT)、戦闘表(CombatIHT)
・命中判定ファンブル表　　(FumbleT)
・致命傷表　　　　　　　　(FatalT)
・アクシデント表　　　　　(AccidentT)
・汎用アクシデント表　　　(GeneralAT)
・その後表　　　　　　　　(AfterT)
・ロマンスファンブル表　　(RomanceFT)
・NPCの年齢と好みを一括出力　(NPCT)
MESSAGETEXT
  end
  
  def dice_command(string, nick_e)
    output_msg = ''
    secret_flg = false
    
    secretMarker = nil
    case string
    when /((^|\s)(\d+)(S)?R[>=]+(\d+)(\[(\d+)?(,\d+)?\])?($|\s))/i
      # 判定ロール
      secretMarker = $4
      command = $1.upcase
      output_msg = satasupe_check(command, nick_e);
    when /(^|\s)(S)?(\w+)($|\s)/i
      # サタスペのチャート処理
      secretMarker = $2
      output_msg = "#{nick_e}: " + satasupe_table($3).join("\n")
    end
    
    return '1', secret_flg if(output_msg == '1');

    if( secretMarker )    # 隠しロール
      secret_flg = true if(output_msg != '1');
    end
    
    return output_msg, secret_flg
  end
  

####################            サタスペ           ########################
  def satasupe_check(string, nick_e)
    debug("satasupe_check begin string", string)
    
    unless(/(^|\s)S?((\d+)(S)?R([>=]+)(\d+)(\[(\d+)?(,\d+)?\])?)($|\s)/i =~ string)
      return '1'
    end
    
    string = $2;
    roll_times = $3.to_i;
    signOfInequality = marshalSignOfInequality($5);
    target = $6.to_i;
    param = $7;
    min_suc = 0;
    fumble = 1;
    
    unless( param.nil? )
      # param => [x,y]
      if( /\[(\d*)(,(\d*))?\]/ =~ param )
        min_suc = $1.to_i
        fumble = $3.to_i if( $2 )
      end
    end
    
    total_suc = 0;
    isFunble = false
    dice_str = "";
    
    debug('roll_times', roll_times)
    roll_times.times do |i|
      debug('index i', i)
      
      debug('min_suc, total_suc', min_suc, total_suc)
      if( min_suc != 0 )
        if(total_suc >= min_suc)
          debug('(total_suc >= min_suc) break')
          break
        end
      end
      
      d1 = rand(6) + 1;
      d2 = rand(6) + 1;
      
      dice_suc = 0;
      dice_suc = 1 if(target <= (d1 + d2));
      dice_str += "+" unless( dice_str.empty? );
      dice_str += "#{dice_suc}[#{d1},#{d2}]";
      total_suc += dice_suc;
      
      if((d1 == d2) and (d1 <= fumble))  # ファンブルの確認
        isFunble = true
        break
      end
    end
    
    output = "#{nick_e}: (#{string}) ＞ #{dice_str} ＞ 成功度#{total_suc}";
    if( isFunble )
      output += " ＞ ファンブル";
    end
    
    debug( 'satasupe_check result output', output )
    return output;
  end


####################            サタスペ           ########################
#** 各種表
  def satasupe_table(string)
    string = string.upcase
    output =[]
    
    counts = 1;
    type = "";
    
    if( /(\D+)(\d+)?/ =~ string )
      type = $1;
      counts = $2.to_i if($2);
    end
    
    #1d6*1d6
    #タグ決定表
    if(type == "TAGT")
      table = [
               '情報イベント',
               'アブノーマル(サ)',
               'カワイイ(サ)',
               'トンデモ(サ)',
               'マニア(サ)',
               'ヲタク(サ)',
               '音楽(ア)',
               '好きなタグ',
               'トレンド(ア)',
               '読書(ア)',
               'パフォーマンス(ア)',
               '美術(ア)',
               'アラサガシ(マ)',
               'おせっかい(マ)',
               '好きなタグ',
               '家事(マ)',
               'ガリ勉(マ)',
               '健康(マ)',
               'アウトドア(休)',
               '工作(休)',
               'スポーツ(休)',
               '同一タグ',
               'ハイソ(休)',
               '旅行(休)',
               '育成(イ)',
               'サビシガリヤ(イ)',
               'ヒマツブシ(イ)',
               '宗教(イ)',
               '同一タグ',
               'ワビサビ(イ)',
               'アダルト(風)',
               '飲食(風)',
               'ギャンブル(風)',
               'ゴシップ(風)',
               'ファッション(風)',
               '情報ハプニング',
              ]
      name = "タグ決定表:";

      counts.times do |i|
        num1 = rand(6);
        num2 = rand(6);
        result = table[num1 * 6 + num2];
        text = "#{name}#{num1 + 1}#{num2 + 1}:#{result}";
        output.push( text );
      end
      
      return output;
    end
    
    
    
    #2d6
    
    name = ''
    table = []
    
    case type
    when /CrimeIET/i
      name = "情報イベント表／〔犯罪〕:";
      table = [
               '謎の情報屋チュンさん登場。ターゲットとなる情報を渡し、いずこかへ去る。情報ゲット！',
               '昔やった仕事の依頼人が登場。てがかりをくれる。好きなタグの上位リンク（SL+2）を１つ得る。',
               '謎のメモを発見……このターゲットについて調べている間、このトピックのタグをチーム全員が所有しているものとして扱う',
               '謎の動物が亜侠を路地裏に誘う。好きなタグの上位リンクを２つ得る',
               '偶然、他の亜侠の仕事現場に出くわす。口止め料の代わりに好きなタグの上位リンクを１つ得る',
               'あまりに適切な諜報活動。コストを消費せず、上位リンクを３つ得る',
               'その道の権威を紹介される。現在と同じタグの上位リンクを２つ得る',
               '捜査は足だね。〔肉体点〕を好きなだけ消費する。その値と同じ数の好きなタグの上位リンクを得る',
               '近所のコンビニで立ち読み。思わぬ情報が手に入る。上位リンクを３つ得る',
               'そのエリアの支配盟約からメッセンジャーが1D6人。自分のチームがその盟約に敵対していなければ、好きなタグの上位リンクを２つ得る。敵対していれば、メッセンジャーは「盟約戦闘員（p.127）」となる。血戦を行え',
               '「三下（p.125）」が1D6人現れる。血戦を行え。倒した数だけ、好きなタグの上位リンクを手に入れる',
              ]
    when /LifeIET/i
      name = "情報イベント表／〔生活〕:";
      table = [
               '謎の情報屋チュンさん登場。ターゲットとなる情報を渡し、いずこかへ去る。情報ゲット！',
               '隣の奥さんと世間話。上位リンクを４つ得る',
               'ミナミで接待。次の１ターン何もできない代わりに、好きなタグの上位リンク（SL+2）を１つ得る',
               '息抜きにテレビを見ていたら、たまたまその情報が。好きなタグの上位リンクを１つ得る',
               '器用に手に入れた情報を転売する。《札巻》を１個手に入れ、上位リンクを３つ得る',
               '情報を得るついでに軽い営業。〔サイフ〕を１回復させ、上位リンクを３つ得る',
               '街の有力者からの突然の電話。そのエリアの盟約の幹部NPCの誰かと【コネ】を結ぶことができる',
               '金をばらまく。〔サイフ〕を好きなだけ消費する。その値と同じ数の任意の上位リンクを得る',
               '〔表の顔〕の同僚が思いがけないアドバイスをくれる。上位リンクを1D6つ得る',
               '謎の情報屋チュンさんが、情報とアイテムのトレードを申し出る。DDの指定するアイテムを１つ手に入れると、どこからともなくチュンさんが現れる。そのアイテムをチュンさんに渡せば、情報ゲット！',
               'ターゲットとは関係ないが、ドデかい情報を掘り当てる。その情報を売って〔サイフ〕が全快する',
               ]
    when /LoveIET/i
      name = "情報イベント表／〔恋愛〕:";
      table = [
               '謎の情報屋チュンさん登場。ターゲットとなる情報を渡し、いずこかへ去る。情報ゲット！',
               '恋人との別れ。自分に恋人がいれば、１人を選んで、お互いのトリコ欄から名前を消す。その代わり情報ゲット！',
               'とびきり美形の情報提供者と遭遇。〔性業値〕判定で律になると、好きなタグの上位リンクを１つ得る',
               '敵対する亜侠と第一種接近遭遇。キスのあとの濡れた唇から、上位リンクを３つ得る',
               '昔の恋人がそれに詳しかったはず。その日の深夜・早朝に行動しなければ、好きなタグの上位リンク（SL+2）を１つ得る',
               '情報はともかくトリコをゲット。データは「女子高生（p.122）」を使用する',
               '関係者とすてきな時間を過ごす。好きなタグの上位リンクを１つ得る。ただし、次の１ターンは行動できない',
               '持つべきものは愛の奴隷。自分のトリコの数だけ好きなタグの上位リンクを得る',
               '自分よりも１０歳年上のイヤなやつに身体を売る。現在と同じタグの上位リンクを１つ得る',
               '有力者からの突然のご指名。チームの仲間を１人、ランダムに決定する。差し出すなら、そのキャラクターは次の１ターン行動できない代わり、その後にそのキャラクターの〔恋愛〕と同じ数の上位リンクを得る',
               '愛する人の死。自分に恋人がいれば、１人選んで、そのキャラクターを死亡させる。その代わり情報ゲット！',
               ];
    when /CultureIET/i
      name = "情報イベント表／〔教養〕:";
      table = [
               '謎の情報屋チュンさん登場。ターゲットとなる情報を渡し、いずこかへ去る。情報ゲット！',
               'ネットで幻のリンクサイトを発見。すべての種類のタグに上位リンクがはられる',
               '間違いメールから恋が始まる。ハンドルしか知らない「女子高生（p.122）」と恋人（お互いのトリコ）の関係になる',
               '新聞社でバックナンバーを読みふける。上位リンクを６つ得る',
               '巨大な掲示板群から必要な情報をサルベージ。好きなタグの上位リンクを１つ得る',
               '検索エンジンにかけたらすぐヒット。コストを消費せず、上位リンクを４つ得る',
               '警察無線を傍受。興味深い。好きなタグの上位リンクを２つ得る',
               'クールな推理がさえ渡る。〔精神点〕を好きなだけ消費する。その値と同じ数だけ好きなタグの上位リンクを得る',
               '図書館ロールが貫通。好きなタグの上位リンク（SL+3)を１つ得る',
               '図書館で幻の書物を発見。上位リンクを８つ得る。キャラクターシートのメモ欄に<クトゥルフ神話知識>、SANと記入し、それぞれ後ろに＋５、−５の数値を書き加える',
               'アジトに謎の手紙が届く。自分のアジトに戻れば、情報ゲット！',
               ];
    when /CombatIET/i
      name = "情報イベント表／〔戦闘〕:";
      table = [
               '謎の情報屋チュンさん登場。ターゲットとなる情報を渡し、いずこかへ去る。情報ゲット！',
               '昔、お前が『更正』させた大幇のチンピラから情報を得る。〔精神点〕を２点減少し、好きなタグの上位リンク（SL+2）を１つ得る。',
               '大阪市警の刑事から情報リーク。「敵の敵は味方」ということか……？　〔精神点〕を３点減少し、上位リンクを６つ得る。',
               '無軌道な若者達を拳で『更正』させる。彼等は涙を流しながら情報を差し出した。……情けは人のためならず。好きなだけ〔精神点〕を減少する。減少した値と同じ数だけ、上位リンクを得る。',
               'クスリ漬けの流氓を拳で『説得』。流氓はゲロと一緒に情報を吐き出した。２点のダメージ（セーブ不可）を受け、好きなタグの上位リンクを１つ得る。',
               '次から次へと糞どもがやってくる。コストを消費せずに上位リンクを３つ得る。',
               '自称『善良な一市民』からの情報リークを受ける。オマエの持っている異能の数だけ上位リンクを得る。……罠か！？',
               'サウナ風呂でくつろぐヤクザから情報収集。ヤクザは歯の折れた口から、弱々しい呻きと共に情報を吐き出した。好きなだけダメージを受ける（セーブ不可）。好きなタグの受けたダメージと同じ値のSLへリンクを１つ得る。',
               'ゼロ・トレランスオンスロートなラブ＆ウォー。2D6を振り、その値が現在の〔肉体点〕以上であれば、情報をゲット！',
               'お前達を狙う刺客が冥土の土産に教えてくれる。お前自身かチームの仲間、お前の恋人のいずれかの〔肉体点〕を０点にすれば、情報をゲットできる。',
               'お前の宿敵（データはブラックアドレス）が1D6体現れる。血戦によって相手を倒せば、情報ゲット。',
               ];
    when /CrimeIHT/i
      name = "情報ハプニング表／〔犯罪〕:";
      table = [
               '謎の情報屋チュンさん登場。ターゲットとなる情報を渡し、いずこかへ去る。情報ゲット！',
               '警官からの職務質問。一晩拘留される。臭い飯表（p.70）を１回振ること',
               'だますつもりがだまされる。〔サイフ〕を１点消費',
               '気のゆるみによる駐車違反。持っている乗物が無くなってしまう',
               '超えてはならない一線を越える。トラウマを１点受ける',
               'そのトピックを取りしきる盟約に目をつけられる。このトピックと同じタグのトピックからはリンクをはれなくなる',
               '過去の亡霊がきみを襲う。自分の修得している異能の中から好きな１つを選ぶ。このセッションでは、その異能が使用不可になる',
               '敵対する盟約のいざこざに巻き込まれる。〔肉体点〕に1D6点のセーブ不可なダメージを受ける',
               'スリにあう。〔通常装備〕からランダムにアイテムを１個選び、それを無くす',
               '敵対する盟約からの妨害工作。この情報は情報収集のルールを使って手に入れることはできなくなる',
               '頼れる協力者のもとへ行くと、彼（彼女）の無惨な姿が……自分の持っている現在のセッションに参加していないキャラクター１体を選び、〔肉体点〕を０にする。そして、致命傷表(p.61）を振ること',
               ];
    when /LifeIHT/i
      name = "情報ハプニング表／〔生活〕:";
      table = [
               '謎の情報屋チュンさん登場。ターゲットとなる情報を渡し、いずこかへ去る。情報ゲット！',
               '経理の整理に没頭。この日の行動をすべてそれに費やさない限り、このセッションでは買物を行えなくなる',
               '壮大なる無駄使い。〔サイフ〕を１点消費',
               '「当たり屋(p.124）」が【追跡】を開始',
               '留守の間に空き巣が！　〔アジト装備〕からランダムにアイテムが１個無くなる',
               '「押し売り(p.124）」が【追跡】を開始',
               '新たな風を感じる。自分の好きな〔趣味〕１つをランダムに変更すること',
               '貧乏ひまなし。［1D6−自分の〔生活〕］ターンの間、行動できなくなる',
               '留守の間にアジトが火事に！　〔アジト装備〕がすべて無くなる。明日からどうしよう？',
               '頼りにしていた有力者が失脚する。しわ寄せがこっちにもきて、〔生活〕が１点減少する',
               '覚えのない借金の返済を迫られる。〔サイフ〕を1D6点減らす。〔サイフ〕が足りない場合、そのセッション終了時までに不足分を支払わないと【借金大王】(p.119）の代償を得る',
               ];
    when /LoveIHT/i
      name = "情報ハプニング表／〔恋愛〕:";
      table = [
               '謎の情報屋チュンさん登場。ターゲットとなる情報を渡し、いずこかへ去る。情報ゲット！',
               '一晩を楽しむが相手はちょっと特殊な趣味だった。アブノーマルの趣味を持っていない限り、トラウマを１点受ける。この日はもう行動できない',
               '一晩を楽しむが相手はちょっと特殊な趣味だった。【両刀使い】の異能を持っていない限り、トラウマを１点受ける。この日はもう行動できない',
               '一晩を楽しむが相手は年齢を10偽っていた。ロマンス判定のファンブル表を振ること',
               'すてきな人を見かけ、一目惚れ。DDが選んだNPC１体のトリコになる',
               '「痴漢・痴女(p.124）」が【追跡】を開始',
               '手を出した相手が有力者の女（ヒモ）だった。手下どもに袋叩きに会い、1D6点のダメージを受ける（セーブ不可）',
               '突然の別れ。トリコ欄からランダムに１体を選び、その名前を消す',
               '乱れた性生活に疲れる。〔肉体点〕と〔精神点〕がともに２点減少する',
               '性病が伝染る。１日以内に病院に行き、治療（価格４）を行わないと、鼻がもげる。鼻がもげると〔恋愛〕が１点減少する',
               '生命の誕生。子供ができる',
               ];
    when /CultureIHT/i
      name = "情報ハプニング表／〔教養〕:";
      table = [
               '謎の情報屋チュンさん登場。ターゲットとなる情報を渡し、いずこかへ去る。情報ゲット！',
               'アヤシイ書物を読み、一時的発狂。この日はもう行動できない。トラウマを１点受ける',
               '天才ゆえの憂鬱。自分の〔教養〕と同じ値だけ、〔精神点〕を減少させる',
               '唐突に睡魔が。次から２ターンの間、睡眠しなくてはならない',
               '間違いメールから恋が始まる。ハンドルしか知らない「女子高生（p.122）」に偽装した「殺人鬼（p.137）」と恋人（お互いのトリコ）の関係になる',
               '「勧誘員(p.124）」が【追跡】を開始',
               'OSの不調。徹夜で再インストール。この日はもう行動できない上、「無理」をしてしまう',
               '場を荒らしてしまう。このトピックと同じタグのトピックからはリンクをはれなくなる',
               'ボケる。〔教養〕が１点減少する',
               'クラッキングに遭う。いままで調べていたトピックとリンクをすべて失う',
               'ネットサーフィンにハマってしまい、ついつい時間が過ぎる。毎ターンのはじめに〔性業値〕判定を行い、律にならないとそのターンは行動できない。この効果は１日続く',
               ];
    when /CombatIHT/i
      name = "情報ハプニング表／〔戦闘〕:";
      table = [
               '謎の情報屋チュンさん登場。ターゲットとなる情報を渡し、いずこかへ去る。情報ゲット！',
               '悪を憎む心に支配され、一匹の修羅と化す。キジルシの代償から１種類を選び、このセッションの間、習得すること。修得できるキジルシの代償がなければ、あなたはNPCとなる。',
               '自宅に帰ると、無惨に破壊された君のおたからが転がっていた。「この件から手を引け」という書き置きと共に……。この情報フェイズでは、リンク判定を行ったトピックのタグの〔趣味〕を修得していた場合、それを未修得にする。また、おたからを持っていたなら、このセッション中、そのおたからは利用できなくなる。',
               '「俺にはもっと別の人生があったんじゃないだろうか……！？」突如、空しさがこみ上げて来る……その日は各ターンの始めに〔性業値〕判定を行う。失敗すると、酒に溺れ、そのターンは行動済みになる。',
               'クライムファイター仲間からスパイの容疑を受ける……１点のトラウマを追う。',
               '自宅の扉にメモが……！！　「今ならまだ間に合う」奴等はどこまで知っているんだ！？　このトピックからは、これ以上リンクを伸ばせなくなる。',
               '大幇とコンビナートの抗争に何故か巻き込まれる。……なんとか生還するが、次のターンの最後まで行動できず、1D6点のダメージを受ける（セーブ不可）',
               '地獄組の鉄砲玉が君に襲い掛かってきた！！　〔戦闘〕で難易度９の判定に失敗すると、〔肉体点〕が０になる。',
               '「お前はやり過ぎた」の書きおきと共に、友人の死体が発見される〔戦闘〕で難易度９の判定を行う。失敗すると、ランダムに選んだチームの仲間１人が死亡する。',
               '宿敵によって深い疵を受ける。自分の修得している異能の中から、１つ選ぶこと。このセッションのあいだ、その異能を使用することができなくなる。',
               '流氓の男の卑劣な罠にかかり、肥え喰らいの巣に落ちる！！　「掃き溜めの悪魔」1D6体と血戦を行う。戦いに勝たない限り、生きて帰ることはできないだろう……。もちろん血戦に勝ったところで情報は得られない。',
              ];
    when /G(eneral)?A(ccident)?T/i
      name = "汎用アクシデント表:";
      table = [
               '痛恨のミス。激しく状況が悪化する。以降のケチャップに関する行為判定の難易度に＋１の修正がつき、あなたが追う側なら逃げる側のコマを２マス進める（逃げる側なら自分を２マス戻す）',
               '最悪の大事故。ケチャップどころではない！　〔犯罪〕で難易度９の判定を行う。失敗したら、ムーブ判定を行ったキャラクターは3D6天のダメージを受け、ケチャップから脱落する。判定に成功すればギリギリ難を逃れる。特に何もなし。',
               'もうダメだ……。絶望感が襲いかかってくる。後３ラウンド以内にケリをつけないと、あなたが追う側なら自動的に逃げる側が勝利する（逃げる側なら追う側が勝利する）',
               'まずい、突発事故だ！　ムーブ判定を行ったキャラクターは、1D6点のダメージを受ける。',
               '一瞬ひやりと緊張が走る。　ムーブ判定を行ったキャラクターは、〔精神点〕を２点減少する。',
               'スランプ！　思わず足踏みしてしまう。ムーブ判定を行った者は、ムーブ判定に使用した能力値を使って難易度７の判定を行うこと。失敗したら、ムーブ判定を行ったキャラクターは、ケチャップから脱落。成功しても、あなたが追う側なら逃げる側のコマを１マス進める（逃げる側なら自分を１マス戻す）',
               'イマイチ集中できない。〔性業値〕判定を行うこと。「激」になると、思わず見とれてしまう。あなたが追う側なら逃げる側のコマを１マス進める（逃げる側なら自分を１マス戻す）',
               '古傷が痛み出す。以降のケチャップに関する行為判定に修正が＋１つく',
               'うっかり持ち物を見失う。〔通常装備〕欄からアイテムを１個選んで消す',
               '苦しい状態に追い込まれた。ムーブ判定を行ったキャラクターは、今後のムーブ判定で成功度が−１される。',
               '頭の中が真っ白になる。〔精神点〕を1D6減少する。',
              ];
    when /R(omance)?F(umble)?T/i
      name = "ロマンスファンブル表:";
      table = [
               'みんなあいそをつかす。自分のトリコ欄のキャラクターの名前をすべて消すこと',
               '痴漢として通報される。〔犯罪〕の難易度９の判定に成功しない限り、1D6ターン後に検挙されてしまう',
               'へんにつきまとわれる。対象は、トリコになるが、ファンブル表の結果やトリコと分かれる判定に成功しない限り、常備化しなくてもトリコ欄から消えることはない',
               '修羅場！　対象とは別にトリコを所有していれば、そのキャラクターが現れ、あなたと対象に血戦をしかけてくる',
               '恋に疲れる。自分の〔精神点〕が1D6点減少する',
               '甘い罠。あなたが対象のトリコになってしまう',
               '平手うち！　自分の〔肉体点〕が1D6点減少する',
               '浮気がばれる。恋人関係にあるトリコがいれば、そのキャラクターの名前をあなたのトリコ欄から消す',
               '無礼な失言をしてしまう。対象はあなたに対し「憎悪（p.120参照）」の反応を抱き、あなたはその対象の名前を書き込んだ【仇敵】の代償を得る',
               'ショックな一言。トラウマを１点受ける',
               'トリコからの監視！　このセッションの間、ロマンス判定のファンブル率が自分のトリコの所持数と同じだけ上昇する',
              ];
    when /FumbleT/i
      name = "命中判定ファンブル表:";
      table = [
               '自分の持ち物がすっぽぬけ、偶然敵を直撃！　持っているアイテムを１つ消し、ジオラマ上にいるキャラクター１人をランダムに選ぶ。そのキャラクターの〔肉体点〕を1D6ラウンドの間０点にし、行動不能にさせる（致命傷表は使用しない）。1D6ラウンドが経過し、行動不能から回復すると、そのキャラクターの〔肉体点〕は、行動不能になる直前の値にまで回復する',
               '敵の増援！　「三下(p.125）」が1D6体現れて、自分たちに襲いかかってくる（DDは、この処理が面倒だと思ったら、ファンブルしたキャラクターの〔肉体点〕を1D6点減少させてもよい）',
               'お前のいるマスに「障害物」が出現！　そのマスに障害物オブジェクトを置き、そのマスにいたキャラクターは全員２ダメージを受ける（セーブ不可）',
               '射撃武器を使っていれば、弾切れを起こす。準備行動を行わないとその武器はもう使えない',
               '転んでしまう。準備行動を行わないと移動フェイズに行動できず、格闘、射撃、突撃攻撃が行えない',
               '急に命が惜しくなる。性業値判定をすること。「激」なら戦闘を続行。「律」なら次のラウンドから全力移動を行い、ジオラマから逃走を試みる。「迷」なら次のラウンドは移動・攻撃フェイズに行動できない',
               '誤って別の目標を攻撃。目標以外であなたに一番近いキャラクターに４ダメージ（セーブ不可）！',
               '誤って自分を攻撃。３ダメージ（セーブ不可）！',
               '今使っている武器が壊れる。アイテム欄から使用中の武器を消すこと。銃器を使っていた場合、暴発して自分に６ダメージ！　武器なしの場合、体を傷つけ３ダメージ（共にセーブ不可）！',
               '「制服警官(p.129）」が１人現れる。その場にいるキャラクターをランダムに攻撃する',
               '最悪の事態。〔肉体点〕を０にして、そのキャラクターは行動不能に（致命傷表は使用しない）',
              ];
    when /FatalT/i
      name = "致命傷表:";
      table = [
               '死亡。',
               '死亡。',
               '昏睡して行動不能。1D6ラウンド以内に治療し、〔肉体点〕を１以上にしないと死亡。',
               '昏睡して行動不能。1D6ターン以内に治療し、〔肉体点〕を１以上にしないと死亡。',
               '大怪我で行動不能。体の部位のどこかを欠損してしまう。任意の〔能力値〕１つが１点減少。',
               '大怪我で行動不能。1D6ターン以内に治療し、〔肉体点〕を１以上にしないと体の部位のどこかを欠損してしまう。任意の〔能力値〕１つが１点減少。',
               '気絶して行動不能。〔肉体点〕の回復には治療が必要。',
               '気絶して行動不能。１ターン後、〔肉体点〕が１になる。',
               '気絶して行動不能。1D6ラウンド後、〔肉体点〕が１になる。',
               '気絶して行動不能。1D6ラウンド後、〔肉体点〕が1D6回復する。',
               '奇跡的に無傷。さきほどのダメージを無効に。',
              ];
    when /AccidentT/i
      name = "アクシデント表:";
      table = [
               'ゴミか何かが降ってきて、視界を塞ぐ。以降のケチャップに関する判定に修正が＋１つく。あなたが追う側なら逃げる側のコマを２マス進める（逃げる側なら自分を２マス戻す）',
               '対向車線の車（もしくは他の船、飛行機）に激突しそうになる。運転手は難易度９の〔精神〕の判定を行うこと。失敗したら、乗物と乗組員全員は3D6のダメージを受けた上に、ケチャップから脱落',
               'ヤバイ、ガソリンがもうない！　後３ラウンド以内にケリをつけないと逃げられ（追いつかれ）ちまう',
               '露店や消火栓につっこむ。その乗物に1D6ダメージ',
               '一瞬ひやりと緊張が走る。〔精神点〕を２点減らす',
               '何かの障害物に衝突する。運転手は難易度７の〔精神〕の判定を行うこと。失敗したら、乗物と乗組員全員は2D6ダメージを受けた上に、ケチャップから脱落。成功しても、あなたが追う側なら逃げる側のコマを１マス進める（逃げる側なら自分を１マス戻す）',
               '走ってる途中に〔趣味〕に関する何かが目に映る。性業値判定を行うこと。「激」になると思わず見とれてしまう。あなたが追う側なら逃げる側のコマを１マス進める（逃げる側なら自分を１マス戻す）',
               '軽い故障が起きちまった。以降のケチャップに関する行為判定に修正が＋１つく',
               'うっかり落し物。〔通常装備〕欄からアイテムを１個選んで消す',
               'あやうく人にぶつかりそうになる。運転手は難易度９の〔精神〕の判定を行う。失敗したら、その一般人を殺してしまう。あなたが追う側なら逃げる側のコマを１マス進める（逃げる側なら自分を１マス戻す）',
               '信号を無視しちまったら後ろで事故が起きた。警察のサイレンが鳴り響いてくる。DDはケチャップの最後尾に警察の乗物を加えろ。データは「制服警官（p.129）」のものを使用',
              ];
    when /AfterT/i
      name = "その後表:";
      table = [
               'ここらが潮時かもしれない。2D6を振り、その目が自分の修得している代償未満であれば、そのキャラクターは引退し、二度と使用できない',
               '苦労の数だけ喜びもある。2D6を振り、自分の代償の数以下の目を出した場合、経験点が追加で１点もらえる',
               '妙な恨みを買ってしまった。【仇敵】（p.95）を修得する。誰が【仇敵】になるかは、DDが今回登場したNPCの中から１人を選ぶ',
               '大物の覚えがめでたい。今回のセッションに登場した盟約へ入るための条件を満たしていれば、その盟約に経験点の消費なしで入ることができる',
               '思わず意気投合。今回登場したNPC１人を選び、そのキャラクターとの【コネ】（p.95）を修得する',
               '今回の事件で様々な教訓を得る。自分の修得しているアドバンスドカルマの中から、汎用以外のものを好きなだけ選ぶ。そのカルマの異能と代償を、別な異能と代償に変更することができる',
               '深まるチームの絆。今回のセッションでミッションが成功していた場合、【絆】（p.95）を修得する',
               '色々な運命を感じる。今回のセッションでトリコができていた場合、経験点の消費なしにそのトリコを常備化することができる。また、自分が誰かのトリコになっていた場合、その人物への【トリコ】(p.95）の代償を得る',
               'やっぱり亜侠も楽じゃないかも。今回のセッションで何かツラい目にあっていた場合、【日常】（p.95）を取得する',
               'くそっ！　ここから出せ！！　今回のセッションで逮捕されていたら、【前科】(p.95）の代償を得る',
               '〔性業値〕が１以下、もしくは１３以上だった場合、そのキャラクターは大阪の闇に消える。そのキャラクターは引退し、二度と使用できない',
              ];
    end
    
    unless( name.empty? )
      counts.times do |i|
        dice, dummy = roll(2, 6);
        result = table[dice - 2];
        text = "#{name}#{dice}:#{result}"
        output.push(text)
      end
      
      return output
    end
    
    #1d6
    if(type == "NPCT")
      #好み／雰囲気表
      lmood = [
               'ダークな',
               'お金持ちな',
               '美形な',
               '知的な',
               'ワイルドな',
               'バランスがとれてる',
              ]
      #好み／年齢表
      lage = [
              '年下が好き。',
              '同い年が好き。',
              '年上が好き。',
             ]
      #年齢表
      age = [
                 '幼年', #6+2D6歳
                 '少年', #10+2D6歳
                 '青年', #15+3D6歳
                 '中年', #25+4D6歳
                 '壮年', #40+5D6歳
                 '老年', #60+6D6歳
                ]
      agen = [
              '6+2D6',  #幼年
              '10+2D6', #少年
              '15+3D6', #青年
              '25+4D6', #中年
              '40+5D6', #壮年
              '60+6D6', #老年
             ]
      
      name = "NPC表:";
      
      counts.times do |i|
        age_type, dummy = roll(1, 6);
        age_type -= 1
        
        agen_text = agen[age_type]
        age_num = agen_text.split(/\+/)
        
        total, dummy = rollDiceAddingUp( age_num[1] );
        ysold = total + age_num[0].to_i;
        
        lmodValue = lmood[(rand 6)]
        lageValue = lage[(rand 3)]
        
        text = "#{name}#{age[age_type]}(#{ysold}):#{lmodValue}#{lageValue}"
        output.push(text)
      end
      
      return output
    end
    
    return output;
  end

end
