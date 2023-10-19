##### incoming text messages

@app.route("/messages", methods=["GET", "POST"])
def incoming_sms():  
    incoming_message = request.form['Body']
    number=request.form['From']
    saveddate1=str(time.ctime());
    ### strip whatsapp text from number
    #numbershort=number.replace('whatsapp:', '')
    numbershort=number
    #db['login1']='hello'
    if numbershort in db:
        messages=eval(db[numbershort]['message'])
        messages.append({"role": "user",   "content":  incoming_message})
        timehist=eval(db[numbershort]['date']);
    else:
        timehist=[saveddate1];
        messages=[{"role": "system", "content":        system_msg},
    {"role": "user", "content": incoming_message}]
        db[numbershort]={'message':json.dumps(messages), 'date': timehist, 'nudges': 0};

    #### avoid answering if in motivational intervi        wing mode

    answer="true"
    if messages[len(messages)-2]['role']=="system" and messages[len(messages)-2]['content'][0:3]=="MS:":
      answer="false"
      db[numbershort]['message']=json.dumps(messages);
      return answer

    if answer=="true":
    #messages=[{"role": "system", "content": prompt},
  #### Restrict history to at most 25 messages
  
      messages_ai=messages;
      if len(messages)>25:
        messages_ai=messages[:1]+messages[-25:];
    ### new code
      response = openai.ChatCompletion.create(
      model="gpt-4",
      messages=messages_ai
      #temperature=0.5
      )
      youranswer=response.choices[0]["message"]  ["content"].strip()

    ### end new code
    #youranswer=get_response(incoming_message)
      resp = MessagingResponse()
    #if len(youranswer)<=1500:
    ##### OLD messaging code #############
    #  resp.message(youranswer)
      #return str(resp)
    ##### END OLD messaging code ##########
    #else:
    ### Split answer into text bites if necessary
      texts = [youranswer[i : i + 1500] for i in range(0,len(youranswer), 1500)]

      for text in texts:  
              client.messages.create(
                              body=text,
                from_='+18776410832',
                            to=numbershort)
              time.sleep(0.5)
        
    ### add answer to messages history
  
      messages.append({"role": "system",   "content":  youranswer})
      db[numbershort]['message']=json.dumps(messages);
      saveddate2=str(time.ctime());
      timehist=timehist+[saveddate1]+[saveddate2];
      db[numbershort]['date']=json.dumps(timehist);
    return str(resp)