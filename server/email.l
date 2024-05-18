unit nodemailer
	object transporter
	js void setup
		const nodemailer = require("nodemailer");
		nodemailer.transporter = nodemailer.createTransport({
			service: 'gmail',
			auth: {
				user: "heiko.weible",
				pass: ""
			},
		});
		let info = await nodemailer.transporter.sendMail({
			from: "Lunchtime Games<heiko.weible@googlemail.com>",
			to: "tina@visual-generation.de",
			subject: "Hello Subject",
			text: "Hello world Text",
			html: "<b>Hello world HTML</b>",
		});
		log(info)
		
class MailAttachment
	string name
	string data
	string contentType
		
unit mail
	object aws, ses
	
	async js void setup
		try {
			mail.aws = await import("@aws-sdk/client-ses");
			mail.ses = new mail.aws.SESClient({ region: "eu-central-1" })
		} catch (error) {
			console.error(error)
		}

	js async string sendEmail: string from
		                       string to
		                       string subject
		                       string message
		if(Platform.isDebug) return "preview"
		try {
			let result = await mail.ses.send(new mail.aws.SendEmailCommand({
				Source: from,
				Destination: {
					ToAddresses: [to]
				},
				Message: {
					Body: {
						Html: {
							Charset: "UTF-8",
							Data: message
						}
					},
					Subject: {
						Charset: 'UTF-8',
						Data: subject
					}
				}
			}))
			return result.$metadata.httpStatusCode
		}
		catch (err) {
			return err.toString()
		}

	js async string sendEmail: string from
		                       string to
		                       string subject
		                       string message
		                       MailAttachment[] attachments
		if(Platform.isDebug) return "preview"
		try {
			let rawEmail = `From: ${from}\nTo: ${to}\nSubject: ${subject}\nMIME-Version: 1.0\nContent-Type: multipart/mixed; boundary="NextPart"\n\n--NextPart\nContent-Type: text/html; charset="UTF-8"\n\n${message}\n\n--NextPart\n`
				
			for(let a of attachments) {
				rawEmail += `Content-Type: ${a.contentType}; name="${a.name}"\nContent-Disposition: attachment; filename="${a.name}"\nContent-Transfer-Encoding: 7BIT\n\n`+a.data+"\n\n--NextPart--"
			}
			console.log(rawEmail)
			
			let result = await mail.ses.send(new mail.aws.SendRawEmailCommand({
				Source: from,
				Destinations: [to],
				RawMessage: {
					Data: new TextEncoder().encode(rawEmail)
				}
			}))
			return result.$metadata.httpStatusCode
		}
		catch (err) {
			return err.toString()
		}

	
	
		
		
