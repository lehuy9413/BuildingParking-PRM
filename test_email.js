const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 587,
  secure: false, // port 587
  auth: {
    user: 'parkingbuilding0206@gmail.com',
    pass: 'ymvtpmosqkihtwtw',
  },
});

async function test() {
  try {
    const info = await transporter.sendMail({
      from: 'Parking System <noreply@parking.com>',
      to: 'test@example.com',
      subject: 'Test Email',
      text: 'This is a test email.',
    });
    console.log('Email sent successfully:', info.messageId);
  } catch (err) {
    console.error('Error sending email:', err);
  }
}

test();
