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
				Destination: { /* required */
					ToAddresses: [to]
				},
				Message: { /* required */
					Body: { /* required */
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
			console.log(result.$metadata.httpStatusCode)
			return result.$metadata.httpStatusCode
		}
		catch (err) {
			return err.toString()
		}

	
	
		
		
